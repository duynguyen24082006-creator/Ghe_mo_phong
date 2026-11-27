function a = ghe3_vehicle_accel(u)
% u=[ga;phanh;goc_vo_lang_rad;van_toc_mps]. Mo hinh xe minh hoa.
u=u(:);U=max(0,u(4));ga=min(1,max(0,u(1)));br=min(1,max(0,u(2)));
ax=(4000*ga-8000*br-.4*U^2-150*tanh(U/.2))/1400;
if U<=0 && ax<0,ax=0;end
delta=min(.12,max(-.12,u(3)/16));ay=min(3,max(-3,U^2/2.6*tan(delta)));
a=[ax;ay];
end
