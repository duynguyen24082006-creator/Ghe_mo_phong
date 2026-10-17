function [L,J,g] = ghe3_geometry(q,p)
% Exact 3-RPS closure. Base R axes tangent to the equilateral base circle.
% q=[h;roll;pitch], passive eta=[x;y;yaw]; R=Rz(yaw)*Ry(pitch)*Rx(roll).
% A local passive solve selects the near-aligned assembly branch.
q=q(:);
if numel(q)~=3 || ~isreal(q) || any(~isfinite(q))
 error('ghe3:pose','q must have three finite real entries.');
end
ph=q(2); th=q(3); cx=cos(ph); sx=sin(ph); cy=cos(th); sy=sin(th);
Rx=[1 0 0;0 cx -sx;0 sx cx]; Ry=[cy 0 sy;0 1 0;-sy 0 cy];
dRx=[0 0 0;0 -sx -cx;0 cx -sx]; dRy=[-sy 0 cy;0 0 0;-cy 0 -sy];
angles=(0:2)*2*pi/3;
alpha=angles+p.baseAngle;
B=p.rb*[cos(alpha);sin(alpha);zeros(1,3)];
A=p.rp*[cos(angles+p.platformAngle);sin(angles+p.platformAngle);zeros(1,3)];
T=[-sin(alpha);cos(alpha);zeros(1,3)];
eta=[0;0;p.baseAngle-p.platformAngle];
for it=1:25
 [R,Rpsi,Rph,Rth]=rotations(eta(3),Ry,Rx,dRy,dRx);
 c=[eta(1:2);q(1)]; r=R*A; D=bsxfun(@plus,r,c)-B;
 C=sum(T.*D,1)'; Ceta=zeros(3); Cq=zeros(3);
 for i=1:3
  Ceta(i,:)=[T(1,i),T(2,i),T(:,i)'*Rpsi*A(:,i)];
  Cq(i,:)=[T(3,i),T(:,i)'*Rph*A(:,i),T(:,i)'*Rth*A(:,i)];
 end
 if rcond(Ceta*diag([p.rp p.rp 1]))<1e-10
  error('ghe3:closure','Passive 3-RPS constraint Jacobian is singular.');
 end
 if norm(C,inf)<1e-12, break; end
 delta=-Ceta\C;
 if abs(delta(3))>0.5, delta=delta*(0.5/abs(delta(3))); end
 eta=eta+delta;
end
if norm(C,inf)>1e-10, error('ghe3:closure','Passive 3-RPS closure failed.'); end
if abs(eta(3)-(p.baseAngle-p.platformAngle))>pi/2
 error('ghe3:branch','Passive solve left the near-aligned assembly branch.');
end
etaq=-Ceta\Cq;
cq=[[0;0;1],[0;0;0],[0;0;0]]; cq(1:2,:)=etaq(1:2,:);
dR=zeros(3,3,3); dR(:,:,1)=Rpsi*etaq(3,1);
dR(:,:,2)=Rph+Rpsi*etaq(3,2); dR(:,:,3)=Rth+Rpsi*etaq(3,3);
L=sqrt(sum(D.^2,1))';
if any(L<1e-10), error('ghe3:geometry','Actuator length approaches zero.'); end
u=bsxfun(@rdivide,D,L'); J=zeros(3); E=zeros(3); JvG=cq;
for j=1:3
 V=dR(:,:,j)*R'; W=(V-V')/2; E(:,j)=[W(3,2);W(1,3);W(2,1)];
 JvG(:,j)=cq(:,j)+dR(:,:,j)*p.com;
 for i=1:3, J(i,j)=u(:,i)'*(cq(:,j)+dR(:,:,j)*A(:,i)); end
end
Js=J*diag([p.rp 1 1])/p.rp;
baseJointAngle=acos(max(-1,min(1,u(3,:))));
topJointAngle=acos(max(-1,min(1,(R*[0;0;1])'*u)));
g=struct('R',R,'dRphi',dR(:,:,2),'dRtheta',dR(:,:,3),'dR',dR, ...
 'B',B,'A',A,'P',bsxfun(@plus,r,c),'r',r,'O',c,'u',u,'E',E,'Js',Js, ...
 'condition',cond(Js),'baseJointAngle',baseJointAngle,'topJointAngle',topJointAngle, ...
 'hingeAxes',T,'passive',eta,'passiveDerivative',etaq,'cDerivative',cq, ...
 'JvG',JvG,'closureResidual',C,'constraintJacobian',Ceta, ...
 'constraintCondition',cond(Ceta*diag([p.rp p.rp 1])));
end

function [R,Rpsi,Rph,Rth]=rotations(psi,Ry,Rx,dRy,dRx)
cz=cos(psi); sz=sin(psi);
Rz=[cz -sz 0;sz cz 0;0 0 1]; dRz=[-sz -cz 0;cz -sz 0;0 0 0];
R=Rz*Ry*Rx; Rpsi=dRz*Ry*Rx; Rph=Rz*Ry*dRx; Rth=Rz*dRy*Rx;
end
