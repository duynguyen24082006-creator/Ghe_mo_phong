function ghe3_plot(r,outdir)
% Standard MATLAB figures; skipped completely by headless run_ghe3(false).
p=r.p; [~,~,g]=ghe3_geometry(r.q(1,:)',p);
fig=figure('Name','Mo hinh 3-RPS: duoi R tiep tuyen, tren S','Color','w');
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
fig2=figure('Name','Kiem tra quy dao va luoi workspace','Color','w');
subplot(2,2,1); plot(r.t,[r.q(:,1)*1000 r.q(:,2:3)*180/pi]); grid on; xlabel('t [s]'); title('h [mm], roll/pitch [deg]'); legend('h','roll','pitch');
subplot(2,2,2); plot(r.t,r.flowAirTotalLpm); grid on; xlabel('t [s]'); ylabel('L/min tai ap khi quyen'); title('Tong nhu cau khi dong thoi, gia thiet cung T');
subplot(2,2,3); plot(r.t,r.condition); grid on; xlabel('t [s]'); title('Condition Jacobian da chuan hoa');
subplot(2,2,4); w=r.workspace; good=w.feasible; d=w.data;
scatter3(d(good,2)*180/pi,d(good,3)*180/pi,d(good,1)*1000,8,[0 .5 0],'filled'); hold on;
if any(~good), scatter3(d(~good,2)*180/pi,d(~good,3)*180/pi,d(~good,1)*1000,12,'r','filled'); end
grid on; xlabel('roll [deg]'); ylabel('pitch [deg]'); zlabel('h [mm]'); title('Luoi mau hinh hoc; chua phai bien lien tuc');
saveas(fig2,fullfile(outdir,'workspace_flow.png'));
end
