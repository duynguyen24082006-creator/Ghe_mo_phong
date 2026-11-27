function test_pbl2_chuong4()
% Test cac kich ban moi; bo test_ghe3_3bar kiem thu thu vien ghe3 rieng.
dest=fullfile(tempdir,'pbl2_geometry_update_tests');
s=pbl2_chuong4(false,dest);
r=s.periodic;
assert(abs(r.p.rb-.420)<eps && abs(r.p.rp-.360)<eps);
assert(abs(r.p.frameBaseSide-1.000)<eps);
assert(abs(r.p.h0-sqrt(.981^2-.060^2))<1e-12);
% New-geometry coupled regression; not the older 577.35-mm upper radius.
assert(abs(r.averageAirDemandLpm-23.0195472232)<1e-5);
assert(abs(max(abs(r.velocities(:)))-0.0254751822069)<1e-8);
% Independent sampled swept-volume integral vs event-integrated air model.
A=pi*.063^2/4; Aa=A-pi*.020^2/4;
Q=60000*(A*max(r.velocities,0)+Aa*max(-r.velocities,0))* ...
 (r.p.pSupply+r.p.pAtm)/r.p.pAtm;
assert(abs(trapz(r.t,sum(Q,2))/(r.t(end)-r.t(1))- ...
 r.averageAirDemandLpm)<0.002);
assert(max(abs(r.velocities(:)))<r.p.maxSpeed);
names=fieldnames(s.events);
for k=1:numel(names)
 r=s.events.(names{k});
 assert(all(isfinite(r.forces(:))));
 assert(max(max(abs(r.qd([1 end],:))))<1e-12);
 assert(max(max(abs(r.qdd([1 end],:))))<1e-12);
 assert(max(abs(r.q(1,:)-r.q(end,:)))<1e-12);
 assert(strcmp(r.averageAirBasis,'entire nonperiodic event'));
 assert(abs(r.averageAirDemandLpm-trapz(r.t,r.flowAirDemandTotalLpm)/ ...
  (r.t(end)-r.t(1)))<1e-12);
 assert(r.referenceResourcesOK && ~r.actualMotionSolved);
 assert(isnan(r.trajectoryAchieved));
 holdMask=r.t>1/(2*r.p.frequency)+0.1 & ...
  r.t<1/r.p.frequency-0.1;
 assert(all(all(r.valveState(holdMask,:)==0)));
 assert(all(r.flowAirTotalLpm(holdMask)==0));
 assert(max(abs(r.airTankBalanceResidual))<1e-5);
end
fprintf('PBL2: baseline and four events PASS (full-event averages, smooth ends, hold, mass balance, flags).\n');
end
