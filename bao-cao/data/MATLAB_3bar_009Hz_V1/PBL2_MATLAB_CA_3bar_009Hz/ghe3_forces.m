function [f,d] = ghe3_forces(q,qd,qdd,p)
% 3-RPS platform Newton-Euler; massless legs, ideal frictionless R/P/S joints.
% f>0 compression. Lateral reactions lambda are along the base hinge axes.
q=q(:); qd=qd(:); qdd=qdd(:);
if numel(qd)~=3 || numel(qdd)~=3 || ~isreal([qd;qdd]) || any(~isfinite([qd;qdd]))
 error('ghe3:rates','qd and qdd must contain three finite real entries.');
end
[L,J,g]=ghe3_geometry(q,p);
if g.condition>1e10, error('ghe3:singular','Force solution is singular or ill-conditioned.'); end
omega=g.E*qd;
epsT=1e-5/max(1,norm(qd));
[~,~,gp]=ghe3_geometry(q+epsT*qd,p);
[~,~,gm]=ghe3_geometry(q-epsT*qd,p);
Edot=(gp.E-gm.E)/(2*epsT); JvGdot=(gp.JvG-gm.JvG)/(2*epsT);
alpha=g.E*qdd+Edot*qd;
aG=g.JvG*qdd+JvGdot*qd;
rG=g.R*p.com; Iw=g.R*p.inertia*g.R';
F=p.mass*(aG+[0;0;p.g])-p.Fexternal;
M=Iw*alpha+cross(omega,Iw*omega)-p.Mexternal;
Q=g.JvG'*F+g.E'*M;
f=J'\Q;
Flegs=g.u*f; Mlegs=zeros(3,1); Wt=zeros(6,3);
for i=1:3
 Mlegs=Mlegs+cross(g.r(:,i),g.u(:,i)*f(i));
 Wt(:,i)=[g.hingeAxes(:,i);cross(g.r(:,i),g.hingeAxes(:,i))];
end
residualWrench=[F-Flegs;M+cross(rG,F)-Mlegs];
Ws=[Wt(1:3,:);Wt(4:6,:)/p.rp];
wr=[residualWrench(1:3);residualWrench(4:6)/p.rp];
lambda=Ws\wr;
constraintWrench=Wt*lambda;
TO=[g.cDerivative;g.E];
baseMoments=zeros(3,3); jointForces=zeros(3,3);
for i=1:3
 jointForces(:,i)=g.u(:,i)*f(i)+g.hingeAxes(:,i)*lambda(i);
 baseMoments(:,i)=cross(g.P(:,i)-g.B(:,i),g.hingeAxes(:,i)*lambda(i));
end
% baseMoments are demands (up to reaction sign), not vendor moment capacities.
d=struct('lengths',L,'J',J,'geometry',g,'Q',Q,'omega',omega, ...
 'alpha',alpha,'aG',aG,'Iw',Iw,'rG',rG,'JvG',g.JvG, ...
 'lateralForces',lambda,'constraintWrench',constraintWrench, ...
 'constraintGeneralizedResidual',TO'*constraintWrench, ...
 'equilibriumResidual',residualWrench-constraintWrench, ...
 'baseMoments',baseMoments,'jointForces',jointForces, ...
 'virtualPowerResidual',f'*(J*qd)-Q'*qd);
end
