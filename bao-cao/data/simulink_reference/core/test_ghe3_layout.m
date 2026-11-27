function test_ghe3_layout()
% Independent tests for frame/anchor separation and assembly angles.
p=ghe3_defaults(); d=ghe3_layout(p);
assert(abs(d.outerFrameSide-1)<eps && abs(d.baseAnchorRadius-.42)<eps);
assert(abs(d.upperAnchorRadius-.36)<eps);
assert(abs(d.baseAnchorSide-sqrt(3)*.42)<1e-12);
assert(abs(d.upperAnchorSide-sqrt(3)*.36)<1e-12);
assert(abs(d.neutralBodyLean-asin(.06/.981))<1e-12);
assert(abs(d.neutralHeight-sqrt(.981^2-.06^2))<1e-12);
assert(abs(d.pointNormalFrameMargin-(1/sqrt(3)-.42)/2)<1e-12);
assert(~d.assemblyClearanceAssessed && ~d.safeDesignCertified);
q0=[p.h0 0 0]; a=ghe3_assembly_diagnostics(q0,p);
assert(max(abs(a.lowerPinRelativeSwing(:)))<1e-12);
assert(max(abs(a.rodEndMisalignmentFixedClocking(:)))<1e-12);
assert(max(abs(a.bodyLeanFromVertical(:)-d.neutralBodyLean))<1e-12);
q=[p.h0+.01 .035 -.04];[~,J,g]=ghe3_geometry(q',p);
h=1e-6; Jfd=zeros(3);
for j=1:3
 e=zeros(3,1);e(j)=h;
 Jfd(:,j)=(ghe3_geometry(q'+e,p)-ghe3_geometry(q'-e,p))/(2*h);
end
assert(norm(J-Jfd,'fro')<1e-8);
a=ghe3_assembly_diagnostics(q,p);
assert(all(a.rodEndMisalignmentFreeClockLowerBound(:)<= ...
 a.rodEndMisalignmentFixedClocking(:)+1e-12));
assert(~a.capacityAssessed && ~a.safeDesignCertified);
assert(max(abs(sum(g.hingeAxes.*g.u,1)))<1e-10);
bad=p;bad.frameBaseSide=0;
caught=false;try ghe3_validate(bad);catch,caught=true;end
assert(caught);
% Frame side changes only frame outline, not anchor or actuator geometry.
p2=p;p2.frameBaseSide=1.2;
assert(max(abs(ghe3_geometry(q',p)-ghe3_geometry(q',p2)))<1e-12);
fprintf('PASS: geometry separation, 3.506deg identity, assembly angles, Jacobian and invalid input checks.\n');
end
