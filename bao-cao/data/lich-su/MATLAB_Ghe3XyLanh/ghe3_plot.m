function ghe3_plot(r,outdir)
% Standard MATLAB figures; skipped completely by headless run_ghe3(false).
% Compatible with MATLAB R2017b: no tiledlayout, yline or exportgraphics.
if ~exist(outdir,'dir'), mkdir(outdir); end
p=r.p; [~,~,g]=ghe3_geometry(r.q(1,:)',p);
fig=figure('Name','Mo hinh 3-RPS: duoi R tiep tuyen, tren S','Color','w', ...
 'Position',[60 60 1100 760],'PaperPositionMode','auto');
subplot(2,2,1); hold on; grid on; axis equal; view(38,24);
ib=[1 2 3 1]; plot3(g.B(1,ib),g.B(2,ib),g.B(3,ib),'k-','LineWidth',2);
plot3(g.P(1,ib),g.P(2,ib),g.P(3,ib),'b-','LineWidth',2);
for i=1:3, plot3([g.B(1,i) g.P(1,i)],[g.B(2,i) g.P(2,i)],[g.B(3,i) g.P(3,i)],'r-','LineWidth',3); end
for i=1:3
 pts=[g.B(:,i)-0.04*g.hingeAxes(:,i),g.B(:,i)+0.04*g.hingeAxes(:,i)];
 plot3(pts(1,:),pts(2,:),pts(3,:),'g-','LineWidth',3);
end
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]'); title('3-RPS; xanh la = truc khop R tiep tuyen');
subplot(2,2,2); plot(r.t,r.lengths*1000); grid on; xlabel('t [s]'); ylabel('L [mm]'); title('Chieu dai xy lanh'); legend('1','2','3');
subplot(2,2,3); plot(r.t,r.forces); grid on; xlabel('t [s]'); ylabel('F [N], nen duong'); title('Luc doc truc theo Newton-Euler');
subplot(2,2,4); plot(r.t,r.velocities); grid on; xlabel('t [s]'); ylabel('dL/dt [m/s]'); title('Van toc xy lanh');
saveas(fig,fullfile(outdir,'kinematics_forces.png'));
fig2=figure('Name','Kiem tra quy dao va luoi workspace','Color','w', ...
 'Position',[60 60 1100 760],'PaperPositionMode','auto');
subplot(2,2,1); plot(r.t,[r.q(:,1)*1000 r.q(:,2:3)*180/pi]); grid on; xlabel('t [s]'); title('h [mm], roll/pitch [deg]'); legend('h','roll','pitch');
subplot(2,2,2); plot(r.t,r.flowAirTotalLpm); hold on;
flowLabels={'Khi nap theo mo hinh'};
if isfield(r,'flowAirDemandTotalLpm')
 plot(r.t,r.flowAirDemandTotalLpm,'--');
 flowLabels{end+1}='Nhu cau quy dao';
end
if isfield(r,'compressorFlowLpm')
 plot(r.t,r.compressorFlowLpm,':');
 flowLabels{end+1}='May nen';
end
grid on; xlabel('t [s]'); ylabel('L/min tai ap khi quyen');
title('Luu luong dong thoi, gia thiet cung T');
if numel(flowLabels)>1, legend(flowLabels,'Location','best'); end
subplot(2,2,3); plot(r.t,r.condition); grid on; xlabel('t [s]'); title('Condition Jacobian da chuan hoa');
subplot(2,2,4); w=r.workspace; good=w.feasible; d=w.data;
if isempty(d)
 text(0.05,0.5,'Workspace grid skipped for this screening run','Units','normalized');
 axis off;
else
scatter3(d(good,2)*180/pi,d(good,3)*180/pi,d(good,1)*1000,8,[0 .5 0],'filled'); hold on;
if any(~good), scatter3(d(~good,2)*180/pi,d(~good,3)*180/pi,d(~good,1)*1000,12,'r','filled'); end
grid on; xlabel('roll [deg]'); ylabel('pitch [deg]'); zlabel('h [mm]'); title('Luoi mau hinh hoc; chua phai bien lien tuc');
end
saveas(fig2,fullfile(outdir,'workspace_flow.png'));

% Supply/valve histories are optional so archived legacy MAT files still plot.
if isfield(r,'valveState') && isfield(r,'tankPressure')
 fig3=figure('Name','Van 5/3 trung vi kin va binh tich ap','Color','w', ...
  'Position',[60 60 1200 820],'PaperPositionMode','auto');
 colours=[0 0.4470 0.7410;0.8500 0.3250 0.0980;0.4660 0.6740 0.1880];
 for i=1:3
  subplot(2,2,i); hold on;
  if isfield(r,'valveCommand')
   stairs(r.t,r.valveCommand(:,i),'--','Color',[0.45 0.45 0.45],'LineWidth',1);
  end
  stairs(r.t,r.valveState(:,i),'-','Color',colours(i,:),'LineWidth',1.3);
  grid on; xlabel('t [s]'); ylabel('Trang thai -1 / 0 / +1');
  set(gca,'YTick',[-1 0 1]); ylim([-1.2 1.2]);
  title(sprintf('Van %d: thu / khoa kin / duoi',i));
  if isfield(r,'valveCommand'), legend('Lenh','Sau tre','Location','best'); end
 end
 subplot(2,2,4); hold on;
 plot(r.t,r.tankPressure/1e5,'b-','LineWidth',1.3);
 if isfield(r,'tankPressureDemand')
  plot(r.t,r.tankPressureDemand/1e5,'--','Color',[0.55 0.2 0.7]);
 end
 pressureSet=p.pSupply;
 if isfield(p,'regulatorPressure'), pressureSet=p.regulatorPressure; end
 plot(r.t,pressureSet/1e5*ones(size(r.t)),'r--','LineWidth',1.1);
 labels={'Binh tich ap'};
 if isfield(r,'tankPressureDemand'), labels{end+1}='Binh theo nhu cau bao thu';end
 labels{end+1}='Ap dat dieu ap';
 if isfield(p,'tankPressureCutIn')
  plot(r.t,p.tankPressureCutIn/1e5*ones(size(r.t)),':','Color',[0.2 0.6 0.2]);
  labels{end+1}='Nguong bat may nen';
 end
 if isfield(p,'tankPressureMax')
  plot(r.t,p.tankPressureMax/1e5*ones(size(r.t)),'k:');
  labels{end+1}='Nguong tat may nen';
 end
 grid on; xlabel('t [s]'); ylabel('Ap suat du [bar]');
 title('Binh 12 L: can bang khi dang nhiet');
 if isfield(p,'tankVolume')
  title(sprintf('Binh %.3g L: can bang khi dang nhiet',1000*p.tankVolume));
 end
 legend(labels,'Location','best','FontSize',9);
 saveas(fig3,fullfile(outdir,'valve_tank.png'));
end
end
