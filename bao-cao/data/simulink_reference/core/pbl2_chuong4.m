function study = pbl2_chuong4(makePlots,outdir)
% PBL2_CHUONG4  Bao cao 3 bar, 0.09 Hz; khong dieu khien phan cung.
% Can cac ham ghe3 trong cung thu muc. Tuong thich API MATLAB R2017b.
% Chay: study = pbl2_chuong4(true,fullfile(pwd,'ket_qua_PBL2'));
if nargin<1, makePlots=true; end
if nargin<2, outdir=fullfile(pwd,'ket_qua_PBL2'); end
if ~exist(outdir,'dir'), mkdir(outdir); end
p=ghe3_defaults();
p.pSupply=0.30e6; p.regulatorPressure=p.pSupply;
p.frameBaseSide=1.000; % Canh NGOAI khung de, khong phai canh noi tam khop.
p.rb=0.420; p.rp=0.360; % Ban kinh tam khop duoi / tren; rp la gia thiet.
p.Lmin=0.731; p.stroke=0.500;
p.massPerson=100; p.massSeat=20; p.mass=120;
p.com=[0;0;100*0.250/120]; p.inertia=diag([10 12 8]);
p.boreDiameter=0.063; p.rodDiameter=0.020;
p.h0=sqrt((p.Lmin+p.stroke/2)^2-(p.rp-p.rb)^2);
p.ampH=0.020; p.ampRoll=4*pi/180; p.ampPitch=4*pi/180;
p.frequency=0.09; p.duration=2/p.frequency; p.dt=0.02;
p.maxSpeed=0.04; p=ghe3_validate(p);
study.periodic=run_ghe3(false,p,fullfile(outdir,'tuan_hoan_009Hz'));
study.layout=ghe3_layout(p);
study.periodic.assembly=ghe3_assembly_diagnostics(study.periodic.q,p);
if makePlots, ghe3_plot(study.periodic,fullfile(outdir,'tuan_hoan_009Hz')); end
% Su kien rieng: heave=0; len nghieng, giu, ve giua bang da thuc bac 5.
% Tr la thoi gian chuyen tu the, KHONG la chu ky cua tin hieu sin.
Tr=1/(2*p.frequency); Th=Tr;
t=(0:p.dt:2*Tr+Th)';
if t(end)<2*Tr+Th, t=[t;2*Tr+Th]; end
[b,bd,bdd]=pulse5(t,Tr,Th);
labels={'tang_toc','phanh','cua_trai','cua_phai'};
axesID=[3 3 2 2]; signs=[-1 1 1 -1];
study.events=struct();
for k=1:4
 q=repmat([p.h0 0 0],numel(t),1); qd=zeros(size(q)); qdd=qd;
 j=axesID(k); amp=signs(k)*4*pi/180;
 q(:,j)=amp*b; qd(:,j)=amp*bd; qdd(:,j)=amp*bdd;
 r=evaluate_reference(t,q,qd,qdd,p);
 study.events.(labels{k})=r;
 export_event(r,fullfile(outdir,[labels{k} '.csv']));
 if makePlots, plot_event(r,labels{k},outdir); end
 fprintf('%s: Qmean %.4f L/min; vmax %.6f m/s; F %.2f..%.2f N\n', ...
  labels{k},r.averageAirDemandLpm,max(abs(r.velocities(:))), ...
  min(r.forces(:)),max(r.forces(:)));
end
if exist('OCTAVE_VERSION','builtin')
 save('-mat7-binary',fullfile(outdir,'study.mat'),'study');
else
 save(fullfile(outdir,'study.mat'),'study','-v7');
end
end

function [b,bd,bdd]=pulse5(t,Tr,Th)
% Hinh thang tron: tang trong Tr, giu Th, giam trong Tr.
b=zeros(size(t)); bd=b; bdd=b;
rise=t>=0 & t<Tr; hold=t>=Tr & t<=Tr+Th;
fall=t>Tr+Th & t<=2*Tr+Th;
u=t(rise)/Tr;
b(rise)=10*u.^3-15*u.^4+6*u.^5;
bd(rise)=(30*u.^2-60*u.^3+30*u.^4)/Tr;
bdd(rise)=(60*u-180*u.^2+120*u.^3)/Tr^2;
b(hold)=1; u=(t(fall)-Tr-Th)/Tr;
b(fall)=1-(10*u.^3-15*u.^4+6*u.^5);
bd(fall)=-(30*u.^2-60*u.^3+30*u.^4)/Tr;
bdd(fall)=-(60*u-180*u.^2+120*u.^3)/Tr^2;
end

function r=evaluate_reference(t,q,qd,qdd,p)
% Dung lai dong hoc va Newton-Euler cua bo ghe3, khong cat quyen dao.
n=numel(t); L=zeros(n,3); v=L; acc=L; F=L; lateral=L;
strokeOK=false(n,1); jointsOK=strokeOK; conditionOK=strokeOK;
for k=1:n
 [Lk,J,g]=ghe3_geometry(q(k,:)',p);
 epsT=1e-5/max(1,norm(qd(k,:)));
 [~,Jp]=ghe3_geometry(q(k,:)'+epsT*qd(k,:)',p);
 [~,Jm]=ghe3_geometry(q(k,:)'-epsT*qd(k,:)',p);
 L(k,:)=Lk'; v(k,:)=(J*qd(k,:)')';
 acc(k,:)=(J*qdd(k,:)'+(Jp-Jm)/(2*epsT)*qd(k,:)')';
 [fk,d]=ghe3_forces(q(k,:)',qd(k,:)',qdd(k,:)',p);
 F(k,:)=fk'; lateral(k,:)=d.lateralForces';
 strokeOK(k)=all(Lk>=p.Lmin & Lk<=p.Lmin+p.stroke);
 jointsOK(k)=all(g.baseJointAngle<=p.maxJointAngle) && ...
  all(g.topJointAngle<=p.maxJointAngle);
 conditionOK(k)=max(g.condition,g.constraintCondition)<=p.maxCondition;
end
r=struct('p',p,'t',t,'q',q,'qd',qd,'qdd',qdd,'lengths',L, ...
 'velocities',v,'accelerations',acc,'forces',F,'lateralForces',lateral, ...
 'strokeOK',strokeOK,'jointsOK',jointsOK,'conditionOK',conditionOK);
air=ghe3_air_supply(t,v,p); r.air=air; names=fieldnames(air);
for k=1:numel(names), r.(names{k})=air.(names{k}); end
% Su kien khong tuan hoan: lay trung binh TOAN ban ghi, khong lay chu ky cuoi.
r.averageAirDemandLpm=trapz(t,r.flowAirDemandTotalLpm)/(t(end)-t(1));
r.averageAirLpm=60*r.tankOutflowVolumeL(end)/(t(end)-t(1));
r.averageAirBasis='entire nonperiodic event';
r.airAverageOK=r.averageAirDemandLpm<=p.compressorFlowLpm*p.compressorMaxDuty+1e-9;
r.airSupplyOK=r.airAverageOK && air.airTankPressureOK && ...
 air.flowCapacityOK && air.valveTrackingFeasible;
r.air.averageAirDemandLpm=r.averageAirDemandLpm;
r.air.averageAirLpm=r.averageAirLpm; r.air.averageAirBasis=r.averageAirBasis;
r.air.airAverageOK=r.airAverageOK; r.air.airSupplyOK=r.airSupplyOK;
r.speedOK=all(abs(v)<=p.maxSpeed,2); r.strength=ghe3_strength(p,r);
r.referenceResourcesOK=all(strokeOK & jointsOK & conditionOK & r.speedOK) ...
 && r.airSupplyOK && all(r.strength.pneumatic.pass(:));
% Chi sàng lọc tai nguyen: chua giai ap 2 buong/vi tri thuc.
r.actualMotionSolved=false; r.trajectoryAchieved=NaN;
r.assembly=ghe3_assembly_diagnostics(q,p);
end

function export_event(r,filename)
data=[r.t r.q r.lengths r.velocities r.accelerations r.forces ...
 r.valveState r.flowAirDemandTotalLpm r.flowAirTotalLpm r.tankPressure];
header=['time_s,h_m,roll_rad,pitch_rad,L1_m,L2_m,L3_m,' ...
 'v1_mps,v2_mps,v3_mps,a1_mps2,a2_mps2,a3_mps2,F1_N,F2_N,F3_N,' ...
 'valve1,valve2,valve3,Q_required_Lpm,Q_credited_Lpm,tank_gauge_Pa'];
fid=fopen(filename,'w');
if fid<0, error('pbl2:io','Cannot write %s.',filename); end
c=onCleanup(@() fclose(fid)); fprintf(fid,'%s\n',header); clear c;
dlmwrite(filename,data,'-append','delimiter',',','precision','%.12g');
end

function plot_event(r,label,outdir)
f=figure('Name',label,'Color','w');
subplot(3,1,1); plot(r.t,1000*(r.lengths-(r.p.Lmin+r.p.stroke/2)));
ylabel('Delta L [mm]'); legend('1','2','3'); grid on;
title([label ' - quy dao YEU CAU']);
subplot(3,1,2); plot(r.t,r.velocities); ylabel('v [m/s]'); grid on;
subplot(3,1,3); plot(r.t,r.forces); ylabel('F [N]'); xlabel('t [s]'); grid on;
print(f,fullfile(outdir,[label '.png']),'-dpng','-r160');
end
