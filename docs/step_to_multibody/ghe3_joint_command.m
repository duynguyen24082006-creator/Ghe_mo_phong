function qJoint = ghe3_joint_command(L,Lcad,qJointAtCAD,axisSign)
% Chieu dai tam khop -> toa do Prismatic, tat ca m.
% axisSign phai duoc xac nhan bang Joint Sensor va chieu +Z cua moi joint.
L=L(:);Lcad=Lcad(:);qJointAtCAD=qJointAtCAD(:);axisSign=axisSign(:);
if numel(L)~=3||numel(Lcad)~=3||numel(qJointAtCAD)~=3||numel(axisSign)~=3|| ...
 any(~isfinite([L;Lcad;qJointAtCAD;axisSign]))||any(abs(axisSign)~=1)
 error('ghe3:jointMapping','Need 3 finite entries and each sign must be +1 or -1.');
end
qJoint=qJointAtCAD+axisSign.*(L-Lcad);
end
