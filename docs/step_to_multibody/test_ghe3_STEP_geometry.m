function report = test_ghe3_STEP_geometry()
[p,cad]=prepare_ghe3_STEP_800();n=0;
assert(abs(p.rb-.8/sqrt(3))<1e-9&&p.rb==p.rp);n=n+1;
[L,J,g]=ghe3_geometry(cad.qAtCAD,p);assert(max(abs(L-.7395))<1e-10);n=n+1;
assert(max(abs(g.B(:)-cad.B(:)))<1e-8);n=n+1;
expected=cad.A+[zeros(2,3);ones(1,3)*.7395];
assert(max(abs(g.P(:)-expected(:)))<1e-8);n=n+1;
Jexpected=[ones(3,1),cad.A(2,:)',-cad.A(1,:)'];assert(norm(J-Jexpected,'fro')<1e-9);n=n+1;
q=cad.qAtCAD+[.002;.01;-.008];[L,J]=ghe3_geometry(q,p);Jfd=zeros(3);
for k=1:3,d=zeros(3,1);d(k)=1e-7;Jfd(:,k)=(ghe3_geometry(q+d,p)-ghe3_geometry(q-d,p))/(2e-7);end
assert(norm(J-Jfd,'fro')<1e-7);n=n+1;
[qback,info]=ghe3_fk(L,p,cad.qAtCAD);assert(info.converged&&norm(qback-q)<1e-8);n=n+1;
blocked=false;try,ghe3_validate(p);catch,blocked=true;end
assert(blocked);n=n+1;
x=ghe3_joint_command([.7405;.7395;.7375],cad.LatCAD,[0;.02;-.03],[1;-1;1]);
assert(norm(x-[.001;.02;-.032])<1e-12);n=n+1;
report=struct('functionTestGroupsPassed',n,'SimulinkTested',false, ...
 'SolidWorksExportTested',false,'strokeConfirmed',false,'hardwareValidated',false);
disp(report);
end
