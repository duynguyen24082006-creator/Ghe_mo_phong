function test_ghe3()
% Independent numerical/analytical checks; no MATLAB toolboxes or figures.
% Keep the independently derived historical fixture explicit. The public
% defaults now separate outer frame geometry and anchor points; do not change
% the old force/energy regression's geometry or mass.
publicDefaults=ghe3_defaults();
p=legacy_parameters(publicDefaults); rng(372,'twister'); count=0;
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
must(norm(flow-r.idealFlowAirLpm,'fro')<1e-9, ...
 'Unmasked swept-flow gauge-to-absolute reference conversion'); count=count+1;
count=count+test_current_defaults(publicDefaults);
count=count+test_closed_center_air(publicDefaults);
count=count+test_pressure_envelope(publicDefaults);
count=count+test_ghe3_3bar();
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
 fprintf(fid,'Current 1000-mm outer frame; rb/rp=420/360mm;120kg;SC63-500 defaults.\n');
 fprintf(fid,'Closed-center deadband and non-grid-aligned transport delay.\n');
 fprintf(fid,'Isothermal tank mass balance, exact relay cutoff and starvation rejection.\n');
 fprintf(fid,'Regulator aliases and time-varying pressure-envelope/static-holding distinctions.\n');
 fprintf(fid,'3-bar aliases, full deadband demand, analytic delay displacement and flow-capacity deficits.\n');
 fprintf(fid,'Required histories preserved, export scope flags, exact duration and 3-bar resource screens.\n');
 fprintf(fid,'MATLAB desktop UI/graphics not exercised; no physical chair/valve tested.\n');
 fclose(fid);
end
end

function p=legacy_parameters(p)
% Explicit historical data for independent regressions derived for the
% original front-leg-1 ordering. New public defaults are tested separately.
if isfield(p,'legAngles'), p=rmfield(p,'legAngles'); end
p.rb=0.42; p.rp=0.36; p.baseAngle=0; p.platformAngle=0;
p.h0=0.48; p.Lmin=0.38; p.stroke=0.20;
p.massPerson=90; p.massSeat=45; p.mass=135; p.g=9.81;
p.com=[0;0;0.30]; p.inertia=diag([10 12 8]);
p.boreDiameter=0.063; p.rodDiameter=0.025;
p.pSupply=0.60e6;
if isfield(p,'regulatorPressure'), p.regulatorPressure=p.pSupply; end
p.pExhaust=0.05e6; p.ratedPressure=0.80e6;
p.maxPoseAngle=20*pi/180; p.maxJointAngle=20*pi/180;
p.pinDiameter=0.016; p.beamSpan=0.8; p.beamE=210e9;
p.maxSpeed=0.20; % Preserve the historical fixture's actual speed limit.
p.ampH=0.02; p.ampRoll=4*pi/180; p.ampPitch=4*pi/180;
p.frequency=0.30; p.duration=8; p.dt=0.02;
p=ghe3_validate(p);
end

function count=test_current_defaults(p)
count=0;
must(abs(p.frameBaseSide-1)<eps && abs(p.rb-.420)<eps && abs(p.rp-.360)<eps && p.mass==120, ...
 'Outer frame side and lower/upper anchor radii are independent; mass120kg');
must(abs(p.stroke-0.5)<eps && abs(p.rodDiameter-0.020)<eps, ...
 'Current defaults use SC63-500 candidate dimensions');
[L,~,g]=ghe3_geometry([p.h0;0;0],p);
must(g.A(1,1)<0 && g.A(2,2)>0 && g.A(2,3)<0, ...
 'Current numbering: rear 1, front-left 2, front-right 3');
must(max(abs(L-(p.Lmin+p.stroke/2)))<1e-7, ...
 'Current neutral height places the piston at half stroke');
f=ghe3_forces([p.h0;0;0],zeros(3,1),zeros(3,1),p);
must(max(abs(f-p.mass*p.g./(3*g.u(3,:)')))<1e-8, ...
 'Current defaults satisfy independent symmetric axial statics');
count=count+1;
end

function count=test_closed_center_air(p)
% These are tests of the stated reduced-order inventory/valve model.
% They do not assert physical position tracking or trapped-chamber holding.
count=0;
p.pSupply=0.45e6; p.regulatorPressure=p.pSupply;
p.tankPressureMax=0.80e6; p.tankPressureCutIn=0.60e6;
p.tankInitialPressure=p.tankPressureMax;
p.compressorFlowLpm=40;
p.valveResponseTime=0.025; p.valveDeadbandSpeed=0.001;
p=ghe3_validate(p);

t=[0;0.01;0.04;0.1;1.0];
a=ghe3_air_supply(t,zeros(numel(t),3),p);
must(all(a.valveState(:)==0) && all(a.valveCommand(:)==0), ...
 'Zero velocity commands and retains the closed-center state');
must(all(a.flowAirLpm(:)==0) && all(a.flowAirDemandLpm(:)==0), ...
 'Closed-center zero-speed swept consumption is exactly zero');
must(max(abs(a.tankPressure-p.tankInitialPressure))<1e-8, ...
 'A full tank with no flow retains its pressure');
check_inventory(a,p); count=count+1;

a=ghe3_air_supply(t,ones(numel(t),3)*0.0009,p);
must(all(a.valveState(:)==0) && all(a.flowAirLpm(:)==0), ...
 'Speeds strictly inside the deadband consume zero swept air');
count=count+1;

% A 25-ms delay must not be rounded to either 20 ms or 30 ms internally.
% These sample states distinguish it from a rounded 20-ms implementation.
t=(0:0.01:0.1)';
a=ghe3_air_supply(t,ones(numel(t),3)*0.01,p);
must(all(a.valveCommand(:)==1), ...
 'A positive requested speed commands extension');
must(all(all(a.valveState(1:3,:)==0)) && all(a.valveState(4,:)==1), ...
 '25-ms pure transport delay is respected on a 10-ms observation grid');
must(all(ismember(a.valveState(:),[-1 0 1])), ...
 'Valve states remain discrete -1/0/+1');
check_inventory(a,p); count=count+1;

% Independent analytic filling volume. The switch-off event is between
% sample times; clipping pressure without recording accepted inflow fails.
fill=p; fill.tankInitialPressure=0.59e6; fill.airTimeStep=60;
t=[0;20;40;60];
a=ghe3_air_supply(t,zeros(numel(t),3),fill);
expectedVolumeL=(fill.tankPressureMax-fill.tankInitialPressure)* ...
 fill.tankVolume*1000/fill.pAtm;
must(abs(a.tankPressure(end)-fill.tankPressureMax)<1e-7, ...
 'Compressor switches off at the exact maximum-pressure event');
must(abs(a.tankInflowVolumeL(end)-expectedVolumeL)<1e-8, ...
 'Accepted compressor volume agrees with the ideal-gas filling solution');
must(all(a.tankPressure<=fill.tankPressureMax+1e-7), ...
 'Relay cutoff never silently overfills the receiver');
check_inventory(a,fill); count=count+1;

% A receiver can reach its minimum at an internal relay event and recover
% before the next output sample. Reporting min(tankPressure) misses it.
dip=p; dip.valveResponseTime=0; dip.valveDeadbandSpeed=0;
dip.pSupply=0.58e6; dip.regulatorPressure=dip.pSupply;
dip.regulatorHeadroom=0.0200005e6;
dip.tankInitialPressure=dip.tankPressureCutIn+1;
dip.valveRatedFlowLpm=1e9; dip.airTimeStep=1;
area=pi*dip.boreDiameter^2/4;
speed=(30/60000)/(3*area*(dip.pSupply+dip.pAtm)/dip.pAtm);
a=ghe3_air_supply([0;1],ones(2,3)*speed,dip);
must(abs(a.minTankPressure-dip.tankPressureCutIn)<1e-6 && ...
 min(a.tankPressure)>a.minTankPressure+0.5, ...
 'Tank minimum includes an interior relay event between output samples');
must(~a.airTankPressureOK, ...
 'An internal pressure dip cannot falsely pass the regulator headroom check');
check_inventory(a,dip); count=count+1;

% Independent constant-demand solution: the regulator remains supplied,
% so credited swept flow is constant and dp/dt is constant when Qc=0.
drain=p; drain.compressorFlowLpm=0; drain.valveResponseTime=0;
t=[0;0.4;1.1;2];
a=ghe3_air_supply(t,ones(numel(t),3)*0.01,drain);
q=sum(a.flowAirLpm(1,:));
must(q>0 && max(abs(sum(a.flowAirLpm,2)-q))<1e-9, ...
 'Supplied constant-speed demand has constant atmospheric-equivalent flow');
expected=drain.tankInitialPressure-drain.pAtm/drain.tankVolume* ...
 (q/60000)*(t-t(1));
must(max(abs(a.tankPressure-expected))<1e-6, ...
 'Receiver pressure follows the analytic constant-demand balance with L/min conversion');
check_inventory(a,drain); count=count+1;

% A small emptying receiver must not become feasible because delivered
% flow vanishes. Required flow and unserved inventory remain observable.
starve=p; starve.compressorFlowLpm=0; starve.valveResponseTime=0;
starve.tankInitialPressure=0.1e6; starve.tankVolume=1e-5;
starve.regulatorHeadroom=0;
t=(0:0.1:2)';
a=ghe3_air_supply(t,ones(numel(t),3)*0.03,starve);
must(~a.airSupplyOK && a.averageAirDemandLpm>0, ...
 'Starvation cannot be accepted merely because actual admitted flow is small');
must(all(a.tankPressure>=-1e-7) && a.tankUnservedVolumeL(end)>0, ...
 'Receiver floor accounts for unserved volume instead of losing mass');
check_inventory(a,starve); count=count+1;

% Likewise, all-closed valves cannot make a finite prescribed displacement
% free. The mismatch travel must fail the requested-motion proxy limit.
blocked=p; blocked.valveDeadbandSpeed=0.02;
t=(0:0.1:2)';
a=ghe3_air_supply(t,ones(numel(t),3)*0.01,blocked);
must(all(a.flowAirLpm(:)==0) && ~a.valveTrackingFeasible && ~a.airSupplyOK, ...
 'Deadband cannot fabricate a feasible zero-air moving trajectory');
count=count+1;

bad=p; bad.tankVolume=0; must_throws(@() ghe3_validate(bad));
bad=p; bad.valveResponseTime=-0.001; must_throws(@() ghe3_validate(bad));
bad=p; bad.tankPressureCutIn=bad.tankPressureMax; must_throws(@() ghe3_validate(bad));
bad=p; bad.compressorFlowLpm=-1; must_throws(@() ghe3_validate(bad));
count=count+1;

% Either public spelling is editable after validation, but two conflicting
% edits must not silently choose the higher pressure and fabricate thrust.
alias=p; alias.pSupply=0.55e6; alias=ghe3_validate(alias);
must(alias.regulatorPressure==0.55e6, ...
 'Editing pSupply synchronizes an otherwise untouched regulatorPressure');
alias=p; alias.regulatorPressure=0.50e6; alias=ghe3_validate(alias);
must(alias.pSupply==0.50e6, ...
 'Editing regulatorPressure synchronizes an otherwise untouched pSupply');
bad=p; bad.pSupply=0.55e6; bad.regulatorPressure=0.50e6;
must_throws(@() ghe3_validate(bad)); count=count+1;
end

function count=test_pressure_envelope(p)
% Supply depletion must reduce the force screen even when the scalar
% regulator setting remains high. Static holding is not moving thrust.
rr=struct('forces',ones(2,3)*230, ...
 'lengths',ones(2,3)*(p.Lmin+p.stroke/2),'qdd',zeros(2,3), ...
 'velocities',ones(2,3)*0.01,'workingPressureAvailable',ones(2,3)*0.10e6);
s=ghe3_strength(p,rr);
must(all(s.pneumatic.nominalPass) && all(~s.pneumatic.pass), ...
 'Low available pressure fails runtime force capacity despite high nominal setting');
rr.workingPressureAvailable(:)=0.15e6;
sMoving=ghe3_strength(p,rr);
rr.velocities(:)=0;
sHolding=ghe3_strength(p,rr);
must(all(~sMoving.pneumatic.pass) && all(sHolding.pneumatic.pass), ...
 'Ideal static holding envelope is distinct from moving-friction thrust');
must(~sHolding.pneumatic.holdingPressureAssessed, ...
 'A static capacity envelope is not a solved trapped-chamber holding state');
count=1;
end

function check_inventory(a,p)
% Compare state inventory with independently accumulated normalized volumes.
change=a.tankPressure-a.tankPressure(1);
volumeBalance=p.pAtm/(p.tankVolume*1000)* ...
 (a.tankInflowVolumeL-a.tankOutflowVolumeL);
must(max(abs(change-volumeBalance))<1e-6, ...
 'Tank mass is conserved, including relay events and supply-floor events');
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
