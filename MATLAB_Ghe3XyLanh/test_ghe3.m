function test_ghe3()
% Independent numerical/analytical checks; no MATLAB toolboxes or figures.
p=ghe3_defaults(); rng(372,'twister'); count=0;
q=[p.h0+0.01;0.05;-0.04];
[L,J]=ghe3_geometry(q,p); Jfd=zeros(3); epsQ=[1e-6;1e-6;1e-6];
for j=1:3
 dq=zeros(3,1); dq(j)=epsQ(j);
 Jfd(:,j)=(ghe3_geometry(q+dq,p)-ghe3_geometry(q-dq,p))/(2*epsQ(j));
end
must(norm(J-Jfd,'fro')<1e-8,'Analytical Jacobian vs independent length differences'); count=count+1;
for i=1:200
 qr=[p.h0+0.035*(rand-0.5);0.14*(rand-0.5);0.14*(rand-0.5)];
 lr=ghe3_geometry(qr,p); q0=qr+[0.008;0.015;-0.012];
 [back,info]=ghe3_fk(lr,p,q0);
 must(info.converged && norm(back-qr)<1e-7,'200 random local IK-FK round trips');
end
count=count+1;
q0=[p.h0;0;0]; [~,~,g]=ghe3_geometry(q0,p);
[f,d]=ghe3_forces(q0,zeros(3,1),zeros(3,1),p);
expected=p.mass*p.g/(3*g.u(3,1));
must(max(abs(f-expected))<1e-9,'Neutral static mg/(3 cos tilt), not mg/3'); count=count+1;
pc=p; pc.com=[0.04;-0.025;0.30];
fc=ghe3_forces(q0,zeros(3,1),zeros(3,1),pc);
Ni=p.mass*p.g/3+2*p.mass*p.g/(3*p.rp^2)*(g.A(1,:)*pc.com(1)+g.A(2,:)*pc.com(2));
must(max(abs(fc-Ni'./g.u(3,:)'))<1e-9,'Eccentric COM equilateral support load formula'); count=count+1;
qd=[0.025;-0.06;0.09]; qdd=[0.12;0.20;-0.15];
[f,d]=ghe3_forces(q,qd,qdd,p);
must(abs(f'*(J*qd)-d.Q'*qd)<1e-10,'Actuator virtual power');
must(norm(d.constraintGeneralizedResidual)<1e-9,'RPS transverse reactions do zero generalized work');
must(norm(d.equilibriumResidual)<1e-8,'Full spatial Newton-Euler equilibrium after transverse reactions');
must(norm(d.geometry.closureResidual)<1e-10,'All three revolute hinge-plane closures');
psi=atan2(sin(q(2))*sin(q(3)),cos(q(2))+cos(q(3)));
expectedXY=[p.rp/2*(d.geometry.R(1,1)-d.geometry.R(2,2));-p.rp*d.geometry.R(2,1)];
must(norm(d.geometry.passive-[expectedXY;psi])<1e-10,'Independent closed-form parasitic x/y/yaw');
must(norm(d.geometry.passive)>1e-5,'Coupled tilt includes nonzero parasitic motion'); count=count+1;
qLag=lagrange_force(q,qd,qdd,p);
must(norm(qLag-d.Q,inf)<3e-3,'Independent finite-difference energy/Lagrange force'); count=count+1;
% Independent Python rigid-body calculation supplied by a separate review.
pr=p; pr.com=[0.04;-0.025;0.30];
[fr,dr]=ghe3_forces([.48;.15;-.12],[.021;.31;-.23],[-.035;.42;.37],pr);
must(norm(fr-[416.23964201;301.43006145;605.41505899],inf)<1e-5,'Independent 3-RPS dynamic force regression');
must(norm(dr.lateralForces-[-44.41168953;24.83697585;24.78894467],inf)<1e-5,'Independent transverse-reaction regression'); count=count+1;
t=0.713; dt=1e-4;
[qt,vt,at]=ghe3_trajectory(t,p);
qp=ghe3_trajectory(t+dt,p); qm=ghe3_trajectory(t-dt,p);
must(norm((qp-qm)/(2*dt)-vt)<1e-8,'Analytical generalized trajectory rate');
must(norm((qp-2*qt+qm)/dt^2-at)<1e-7,'Analytical generalized trajectory acceleration');
[lt,jt]=ghe3_geometry(qt',p); lp=ghe3_geometry(qp',p); lm=ghe3_geometry(qm',p);
must(norm((lp-lm)/(2*dt)-jt*vt')<1e-8,'Actuator velocity against time difference');
epsT=1e-5; [~,jp]=ghe3_geometry(qt'+epsT*vt',p); [~,jm]=ghe3_geometry(qt'-epsT*vt',p);
analyticA=jt*at'+((jp-jm)/(2*epsT))*vt';
must(norm((lp-2*lt+lm)/dt^2-analyticA)<1e-7,'Actuator acceleration against time difference'); count=count+1;
rr=struct('forces',[500 600 700;-100 -200 -300],'lengths',ones(2,3)*0.52,'qdd',zeros(2,3));
s=ghe3_strength(p,rr);
must(max(abs(s.design.compression-p.loadFactor*[500 600 700]))<1e-9,'Design compression envelope');
must(max(abs(s.design.tension-p.loadFactor*[100 200 300]))<1e-9,'Design tension envelope');
must(all(isnan(s.rod.eulerCriticalLoad)) && all(~s.rod.eulerApplicable),'Stocky rods keep Euler unassessed');
pl=p; pl.rodUnsupportedBase=1.2; ss=ghe3_strength(pl,rr);
must(all(ss.rod.eulerApplicable) && all(isfinite(ss.rod.eulerCriticalLoad)),'Slender rods allow Euler screen');
low=p; low.pSupply=0.06e6; low.pExhaust=0.05e6; sl=ghe3_strength(low,rr);
must(any(~sl.pneumatic.pass),'Low pressure reproducibly fails actuator thrust screen');
pii=p; pii.pSupply=0.04e6; pii.pExhaust=0.05e6; bad=ghe3_strength(pii,rr);
must(all(~bad.pneumatic.pass),'Nonpositive thrust capacity cannot pass'); count=count+1;
% Independent closed-end Lame identity at the inside wall.
a=p.boreDiameter/2; b=a+p.cylinderWall;
vm=sqrt(3)*p.pSupply*b^2/(b^2-a^2);
must(abs(s.cylinder.vonMisesStress-vm)<1e-7,'Lame von Mises identity'); count=count+1;
bad=p; bad.rodDiameter=bad.boreDiameter; must_throws(@() ghe3_validate(bad));
bad=p; bad.loadFactor=0.5; must_throws(@() ghe3_validate(bad));
bad=p; bad.nStrength=0.5; must_throws(@() ghe3_validate(bad));
bad=p; bad.inertia=diag([1 1 10]); must_throws(@() ghe3_validate(bad));
must_throws(@() ghe3_geometry([NaN;0;0],p)); count=count+1;
noPerson=p; noPerson.massPerson=0; noPerson=ghe3_validate(noPerson);
must(noPerson.mass==p.massSeat,'No-person setup allowed with positive moving assembly mass');
% Complete headless workflow, feasibility and transverse-constraint residuals.
r=ghe3_simulate(p);
must(all(r.strokeOK) && all(r.jointsOK) && all(r.conditionOK) && all(r.speedOK), ...
 'Default benchmark satisfies entered geometric/speed limits');
must(all(r.fkOK) && max(r.fkError)<1e-7,'Trajectory FK tracking on local branch');
must(max(abs(r.constraintResidual(:)))<1e-8,'Constraint virtual-work residual entire trajectory');
must(max(abs(r.equilibriumResidual(:)))<1e-8,'Spatial equilibrium entire trajectory');
must(max(abs(r.closureResidual(:)))<1e-10,'Revolute plane closure entire trajectory');
must(max(abs(r.flowAirTotalLpm-sum(r.flowAirLpm,2)))<1e-10,'Concurrent supply flow sum');
A=pi*p.boreDiameter^2/4; Aa=A-pi*p.rodDiameter^2/4;
flow=(A*max(r.velocities,0)+Aa*max(-r.velocities,0))*((p.pSupply+p.pAtm)/p.pAtm)*60000;
must(norm(flow-r.flowAirLpm,'fro')<1e-9,'Gauge-to-absolute flow reference conversion'); count=count+1;
fprintf('PASS: %d test groups, including 200 random IK-FK poses, independent statics/energy, derivatives, invalid inputs and pressure failure.\n',count);
logfile=fullfile(fileparts(mfilename('fullpath')),'test_report.txt');
fid=fopen(logfile,'w');
if fid>=0
 fprintf(fid,'PASS: %d scientific/numerical test groups\n',count);
 fprintf(fid,'Runtime version: %s\n',version());
 fprintf(fid,'200 random IK-FK round trips; analytical Jacobian vs differences.\n');
 fprintf(fid,'Independent symmetric/eccentric statics; closed-form RPS closure/parasitic motion.\n');
 fprintf(fid,'Independent Lagrange energy and Python dynamic-force regression.\n');
 fprintf(fid,'Full spatial equilibrium and zero virtual power of transverse constraints.\n');
 fprintf(fid,'Trajectory/actuator derivatives; invalid-input rejection; no-person case.\n');
 fprintf(fid,'Euler applicability/NaN preservation; low/nonpositive-pressure-capacity failures.\n');
 fprintf(fid,'Headless default trajectory and simultaneous atmospheric-equivalent flow.\n');
 fprintf(fid,'MATLAB desktop UI/graphics not exercised; no physical chair/valve tested.\n');
 fclose(fid);
end
end

function Q=lagrange_force(q,v,a,p)
% Central differences of energy; independent body-frame angular kinematics.
dt=3e-5; dq=3e-5;
momentumP=energy_grad_v(q+dt*v+0.5*dt^2*a,v+dt*a,p,dq);
momentumM=energy_grad_v(q-dt*v+0.5*dt^2*a,v-dt*a,p,dq);
gradT=zeros(3,1); gradV=gradT;
for j=1:3
 d=zeros(3,1); d(j)=dq;
 [tp,vp]=energy(q+d,v,p); [tm,vm]=energy(q-d,v,p);
 gradT(j)=(tp-tm)/(2*dq); gradV(j)=(vp-vm)/(2*dq);
end
Q=(momentumP-momentumM)/(2*dt)-gradT+gradV;
end

function mom=energy_grad_v(q,v,p,dq)
mom=zeros(3,1);
for j=1:3
 d=zeros(3,1); d(j)=dq;
 tp=energy(q,v+d,p); tm=energy(q,v-d,p); mom(j)=(tp-tm)/(2*dq);
end
end

function [T,V]=energy(q,v,p)
% Independent closed-form standard 3-RPS branch, no production functions.
ph=q(2); th=q(3); psi=atan2(sin(ph)*sin(th),cos(ph)+cos(th));
den=1+cos(ph)*cos(th); psidot=(sin(th)*v(2)+sin(ph)*v(3))/den;
Rx=[1 0 0;0 cos(ph) -sin(ph);0 sin(ph) cos(ph)];
Ry=[cos(th) 0 sin(th);0 1 0;-sin(th) 0 cos(th)];
Rz=[cos(psi) -sin(psi) 0;sin(psi) cos(psi) 0;0 0 1];
R=Rz*Ry*Rx;
w=[0;0;psidot]+Rz*[0;1;0]*v(3)+Rz*Ry*[1;0;0]*v(2);
W=[0 -w(3) w(2);w(3) 0 -w(1);-w(2) w(1) 0]; Rd=W*R;
cdot=[p.rp/2*(Rd(1,1)-Rd(2,2));-p.rp*Rd(2,1);v(1)];
rG=R*p.com; vG=cdot+Rd*p.com; wb=R'*w;
T=0.5*p.mass*(vG'*vG)+0.5*wb'*p.inertia*wb;
V=p.mass*p.g*(q(1)+rG(3));
end

function must(check,message)
if ~check, error('ghe3:test','FAILED: %s',message); end
end

function must_throws(fun)
did=false;
try, fun(); catch, did=true; end
must(did,'Invalid input must throw an error');
end
