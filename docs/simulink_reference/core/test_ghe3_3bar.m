function count=test_ghe3_3bar()
% Additional scientific regression tests. Can be run alone or by test_ghe3.
count=0; p=ghe3_defaults();
assert(p.pSupply==0.30e6 && p.regulatorPressure==0.30e6, ...
 'Default pressure aliases must both be 3 bar gauge.');
legacy=rmfield(p,{'pSupply','regulatorPressure','regulatorLastSyncedPressure'});
legacy=ghe3_air_defaults(legacy);
assert(legacy.pSupply==0.30e6 && legacy.regulatorPressure==legacy.pSupply);
count=count+1;
% Independent analytic constant-speed delay: missed distance = v*tau.
p.valveResponseTime=0.025;p.valveDeadbandSpeed=0;p=ghe3_validate(p);
t=[0;0.01;0.04;0.1;0.2];v=ones(numel(t),3)*0.01;
a=ghe3_air_supply(t,v,p);
assert(max(abs(a.flowTrackingErrorProxy(end,:)+0.01*0.025))<1e-12);
assert(max(abs(a.unservedTravel(end,:)-0.01*0.025))<1e-12);
assert(~a.actualMotionSolved && isnan(a.trajectoryAchieved));
assert(isequal(v,ones(numel(t),3)*0.01),'Input velocity may not be modified.');
count=count+1;
% Inside deadband, inlet is closed but nonzero requested travel remains.
p.valveDeadbandSpeed=0.001;t=(0:0.1:10)';
a=ghe3_air_supply(t,ones(numel(t),3)*0.0009,p);
A=pi*p.boreDiameter^2/4;
expected=3*A*0.0009*(p.pSupply+p.pAtm)/p.pAtm*60000;
assert(all(a.flowAirLpm(:)==0) && a.averageAirDemandLpm>0);
assert(abs(a.averageAirDemandLpm-expected)<1e-9);
assert(max(abs(a.flowTrackingErrorProxy(end,:)+0.009))<1e-12);
assert(~a.airSupplyOK && ~a.valveTrackingFeasible);
count=count+1;
% Finite flow conductance must produce a deficit rather than free motion.
p.valveDeadbandSpeed=0;p.valveResponseTime=0;p.valveRatedFlowLpm=0.1;
t=(0:0.01:1)';v=ones(numel(t),3)*0.05;
a=ghe3_air_supply(t,v,p);
assert(~a.flowCapacityOK && ~a.airSupplyOK && ~a.valveTrackingFeasible);
assert(max(abs(a.flowSupportedVelocities(:)))<0.05);
assert(a.flowTrackingMaxError>0.003 && all(a.unservedTravel(end,:)>0.003));
assert(~a.actualMotionSolved && isnan(a.trajectoryAchieved));
count=count+1;
% Zero-speed ideal holding creates no new inlet flow or proxy displacement.
p=ghe3_defaults();t=[0;0.1;1];a=ghe3_air_supply(t,zeros(3,3),p);
assert(all(a.flowSupportedDisplacement(:)==0) && all(a.flowAirLpm(:)==0));
assert(all(a.flowTrackingErrorProxy(:)==0) && ~a.actualMotionSolved);
count=count+1;
% Exact duration survives a noninteger duration/dt; legacy histories stay requested.
p.duration=0.103;p.computeWorkspace=false;p.computeFK=false;
r=ghe3_simulate(p);
assert(r.t(end)==p.duration);
assert(isequal(r.lengths,r.requestedLengths) && isequal(r.velocities,r.requestedVelocities));
assert(isequal(r.forces,r.requestedForces) && ~r.actualMotionSolved && isnan(r.trajectoryAchieved));
assert(max(abs(r.flowSupportedLengthProxy(:)-r.lengths(:)-r.flowTrackingErrorProxy(:)))<1e-12);
count=count+1;
% Export flags/columns prevent falsely labelling a prescribed pose as achieved.
folder=tempname();mkdir(folder);cleanup=onCleanup(@() rmdir(folder,'s'));
ghe3_export(r,folder);
s=fileread(fullfile(folder,'summary.csv'));c=fileread(fullfile(folder,'trajectory.csv'));
assert(~isempty(strfind(s,'actual_motion_solved,0')));
assert(~isempty(strfind(s,'trajectory_achieved,NaN')));
assert(~isempty(strfind(c,'flow_proxy_L1_m')) && ~isempty(strfind(c,'ideal_required_air1_Lpm')));
assert(~isempty(strfind(fileread(fullfile(folder,'screening_notes.txt')),'not achieved motion')));
count=count+1;
end
