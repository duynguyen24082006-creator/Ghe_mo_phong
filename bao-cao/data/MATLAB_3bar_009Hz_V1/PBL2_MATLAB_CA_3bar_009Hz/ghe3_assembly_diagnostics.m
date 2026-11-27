function d = ghe3_assembly_diagnostics(q,p)
%GHE3_ASSEMBLY_DIAGNOSTICS Kinematic angles, not joint capacity approval.
% q: N-by-3 [h roll pitch], or a three-entry column vector.
% Lower R pin is horizontal/tangent. Upper CA pin is tangent in plate frame.
% Rod-end housing bore is assumed fixed-clocked parallel to lower pin axis.
% Do NOT equate old leg/platform-normal cone with catalogue PH misalignment.
if isvector(q) && numel(q)==3,q=reshape(q,1,3);end
if ~isnumeric(q)||~isreal(q)||size(q,2)~=3||any(~isfinite(q(:)))
 error('ghe3:assembly','q must contain finite real N-by-3 pose rows.');
end
layout=ghe3_layout(p);
[~,~,g0]=ghe3_geometry([p.h0;0;0],p);
n=size(q,1);lean=zeros(n,3);swing=lean;misalignment=lean;freeMin=lean;cone=lean;
for k=1:n
 [~,~,g]=ghe3_geometry(q(k,:)',p);
 for i=1:3
  a=g.hingeAxes(:,i);u0=g0.u(:,i);u=g.u(:,i);
  lean(k,i)=atan2(norm(u(1:2)),u(3));
  swing(k,i)=atan2(a'*cross(u0,u),u0'*u);
  movingPin=g.R*layout.upperPinAxesBody(:,i);
  % Cross/dot atan2 is stable near zero; pin axis is an unoriented line.
  misalignment(k,i)=atan2(norm(cross(a,movingPin)),abs(a'*movingPin));
  freeMin(k,i)=asin(min(1,abs(u'*movingPin)));
 end
 cone(k,:)=g.topJointAngle;
end
d=struct('units','rad','neutralBodyLean',layout.neutralBodyLean, ...
 'bodyLeanFromVertical',lean,'lowerPinRelativeSwing',swing, ...
 'rodEndMisalignmentFixedClocking',misalignment, ...
 'rodEndMisalignmentFreeClockLowerBound',freeMin, ...
 'legacyPlatformNormalCone',cone,'capacityAssessed',false, ...
 'safeDesignCertified',false);
d.assumptions=['Upper CA pins are tangent in the moving plate frame. ', ...
 'Rod-end housings stay clocked parallel to each fixed lower tangent pin. ', ...
 'Spherical-bearing misalignment is an unoriented-axis angle. Different ', ...
 'pin placement or rod clocking requires a different computation; round rods ', ...
 'can rotate if not constrained. The free-clock value is only a lower bound. Catalogue ', ...
 'PH, swiveling envelope, CA clearance and side-load ratings are unverified.'];
end
