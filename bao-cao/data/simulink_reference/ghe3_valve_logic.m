function [next,z] = ghe3_valve_logic(state,u,Ts,delay,dwellMin)
% state=[z(3);pending(3);age(3);dwell(3)], u=[s_ref(3);s_measured(3)].
% Pure function, khong sua persistent. Cho phep test doc lap.
z=state(1:3);pending=state(4:6);age=state(7:9);dwell=state(10:12)+Ts;
e=u(1:3)-u(4:6);request=z;
for i=1:3
 if abs(e(i))<.0005,request(i)=0;
 elseif e(i)>.0015,request(i)=1;
 elseif e(i)<-.0015,request(i)=-1;end
 if request(i)==z(i),pending(i)=z(i);age(i)=0;
 else
  if request(i)~=pending(i),pending(i)=request(i);age(i)=0;
  else,age(i)=age(i)+Ts;end
  if age(i)>=delay && dwell(i)>=dwellMin,z(i)=pending(i);age(i)=0;dwell(i)=0;end
 end
end
next=[z;pending;age;dwell];
end
