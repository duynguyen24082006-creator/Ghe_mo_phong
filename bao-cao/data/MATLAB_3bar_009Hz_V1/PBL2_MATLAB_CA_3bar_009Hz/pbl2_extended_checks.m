function checks=pbl2_extended_checks(outdir)
%PBL2_EXTENDED_CHECKS Reproduce 120s air, 50ms sensitivity and pose grids.
% First run pbl2_chuong4(false,outdir). Results remain prescribed-motion screens.
if nargin<1,outdir=fullfile(pwd,'ket_qua_PBL2');end
file=fullfile(outdir,'study.mat');
if ~exist(file,'file'),error('pbl2:results','Run pbl2_chuong4 first: %s',file);end
s=load(file);r=s.study.periodic;p=r.p;
t=(0:.02:120)';phase=mod(t,1/p.frequency);
v=interp1(r.t,r.velocities,phase,'linear');
checks.longrun009Hz=ghe3_air_supply(t,v,p);checks.longrun009Hz.t=t;
p50=p;p50.valveResponseTime=.050;
checks.sensitivity50ms=ghe3_air_supply(r.t,r.velocities,p50);
checks.sensitivity50ms.t=r.t;
angles=[0 0;0 -4;0 4;4 0;-4 0;0 -15;0 15;15 0;-15 0]*pi/180;
checks.staticPoseData=zeros(size(angles,1),12);
for k=1:size(angles,1)
 q=[p.h0;angles(k,:)'];
 [fk,ds]=ghe3_forces(q,zeros(3,1),zeros(3,1),p);
 [L,~,g]=ghe3_geometry(q,p);
 checks.staticPoseData(k,:)=[angles(k,:)*180/pi fk' L' ...
  max(g.baseJointAngle)*180/pi max(g.topJointAngle)*180/pi ...
  max(abs(ds.lateralForces)) max(sqrt(sum(ds.baseMoments.^2,1)))];
end
checks.grid4=pose_grid(p,4);checks.grid15=pose_grid(p,15);
if exist('OCTAVE_VERSION','builtin')
 save('-mat7-binary',fullfile(outdir,'extended_checks.mat'),'checks');
else
 save(fullfile(outdir,'extended_checks.mat'),'checks','-v7');
end
fprintf('Extended checks saved; no actual coupled motion solved.\n');
end

function out=pose_grid(p,ampDeg)
h=p.h0+[-p.ampH 0 p.ampH];a=linspace(-ampDeg,ampDeg,5)*pi/180;
q=zeros(numel(h)*numel(a)^2,3);k=0;
for hi=h
 for ph=a
  for th=a,k=k+1;q(k,:)=[hi ph th];end
 end
end
as=ghe3_assembly_diagnostics(q,p);rows=zeros(k,8);
for i=1:k
 [L,~,g]=ghe3_geometry(q(i,:)',p);
 rows(i,:)=[L' max(g.baseJointAngle) max(g.topJointAngle) ...
  g.condition g.constraintCondition double(all(L>=p.Lmin & L<=p.Lmin+p.stroke))];
end
out=struct('q',q,'data',rows,'assembly',as,'amplitudeDegrees',ampDeg, ...
 'sampledOnly',true,'safeDesignCertified',false, ...
 'columns','L1_m,L2_m,L3_m,maxBaseCone_rad,maxTopCone_rad,condition,passiveCondition,strokeOK');
end
