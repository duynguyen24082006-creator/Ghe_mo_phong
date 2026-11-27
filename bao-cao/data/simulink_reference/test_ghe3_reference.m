function report = test_ghe3_reference()
% Test ham so; khong thay cho load/compile/sim trong Simulink.
p=ghe3_reference_init();n=0;
L=ghe3_reference_ik([p.h0;0;0]);assert(max(abs(L-.981))<1e-10);n=n+1;
a=ghe3_vehicle_accel([.35;0;0;0]);assert(a(1)>0&&a(2)==0);n=n+1;
a=ghe3_vehicle_accel([0;.2;0;10]);assert(a(1)<0);n=n+1;
a=ghe3_vehicle_accel([0;0;.2;5]);b=ghe3_vehicle_accel([0;0;.2;10]);assert(abs(b(2)-4*a(2))<1e-12);n=n+1;
a=ghe3_tilt_reference([1;1;1]);assert(a(2)>0&&a(3)<0);n=n+1;
a=ghe3_tilt_reference([20;20;1]);assert(all(abs(a(2:3))<=4*pi/180+eps));n=n+1;
a=ghe3_tilt_reference([1;1;0]);assert(norm(a-[p.h0;0;0])==0);n=n+1;
s=[zeros(9,1);ones(3,1)*1000];u=[.005;-.005;0;0;0;0];
for k=0:2,[s,z]=ghe3_valve_logic(s,u,.01,.025,.08);assert(all(z==0));end
[s,z]=ghe3_valve_logic(s,u,.01,.025,.08);assert(isequal(z,[1;-1;0]));n=n+1;
for k=1:3,[s,z]=ghe3_valve_logic(s,zeros(6,1),.01,.025,.08);assert(isequal(z,[1;-1;0]));end
for k=1:6,[s,z]=ghe3_valve_logic(s,zeros(6,1),.01,.025,.08);end
assert(all(z==0));n=n+1;
report=struct('functionGroupsPassed',n,'SimulinkCompiled',false,'hardwareValidated',false);disp(report);
end
