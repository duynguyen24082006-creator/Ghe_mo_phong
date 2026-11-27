function q = ghe3_tilt_reference(u)
% u=[ax_LP;ay_LP;enable]. x truoc, y trai, z len. Pitch am = nga sau.
p=evalin('base','ghe3_reference_parameters');u=u(:);
if u(3)<.5,q=[p.h0;0;0];return;end
th=-asin(min(1,max(-1,.5*u(1)/p.g)));
ph=asin(min(1,max(-1,.5*u(2)/(p.g*cos(th)))));
scale=max([1;abs(ph)/(4*pi/180);abs(th)/(4*pi/180)]);
q=[p.h0;ph/scale;th/scale];
end
