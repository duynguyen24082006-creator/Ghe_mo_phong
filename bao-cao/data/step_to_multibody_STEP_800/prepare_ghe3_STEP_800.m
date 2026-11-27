function [pCAD,cad] = prepare_ghe3_STEP_800()
% Ban sao CHI DE TINH HINH HOC. Khong ghi de ghe3_defaults.m cu.
% Chua xac nhan Lmin/stroke/canh khung/COM/inertia tu CAD.
root=fileparts(mfilename('fullpath'));core=fullfile(root,'core');
if ~exist(core,'dir'),core=fullfile(root,'..','simulink_reference','core');end
addpath(core);
pCAD=ghe3_defaults();
xy=[-1943.250002026,872.313120644; ...
    -1250.429677506,472.313121690; ...
    -1943.250000374,72.313119874]'; % mm, nhan C1/C2/C3 cua hinh CAD
center=mean(xy,2);
Bxy=(xy-center)/1000;
radii=sqrt(sum(Bxy.^2,1));radius=mean(radii);
pCAD.rb=radius;pCAD.rp=radius;
pCAD.baseAngle=0;pCAD.platformAngle=0;
pCAD.legAngles=atan2(Bxy(2,:),Bxy(1,:));
pCAD.h0=(803.5-64)/1000; % O dat tai tam mat phang chot DUOI, Z=64 mm
% Khong duoc tai su dung 731 mm/500 mm/canh khung 1000 mm nhu so do CAD.
% NaN co chu dich chan ghe3_validate/ghe3_simulate cho den khi xac nhan.
pCAD.Lmin=NaN;pCAD.stroke=NaN;pCAD.frameBaseSide=NaN;
pCAD.layoutNote='CAD C1/C2/C3; rb=rp~461.880216 mm; CAD pose not confirmed neutral.';
cad.source='shapr3d_export_2026-10-19_07h47m.step';
cad.labels={'CAD_C1','CAD_C2','CAD_C3'};
cad.originWorld_m=[center/1000;.064];
cad.B=[Bxy;zeros(1,3)];cad.A=cad.B;
cad.LatCAD=.7395*ones(3,1);cad.qAtCAD=[.7395;0;0];
cad.oldParametersNotIdentified={'Lmin','stroke','frameBaseSide','massSeat','com','inertia'};
cad.readyForFullSimulation=false;
[L,J,g]=ghe3_geometry(cad.qAtCAD,pCAD);
assert(max(abs(L-cad.LatCAD))<1e-10);
assert(max(abs(g.B(:)-cad.B(:)))<1e-8);
cad.JatCAD=J;
fprintf('Geometry only: rb=rp %.9f m; Lcad %.6f m. C1/C2/C3 are CAD labels.\n',radius,L(1));
end
