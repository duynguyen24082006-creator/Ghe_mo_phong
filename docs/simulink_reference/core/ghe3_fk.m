function [q,info] = ghe3_fk(Ltarget,p,q0)
% Local damped Newton FK. q0 selects a local assembly branch; not unique FK.
if nargin<3, q0=[p.h0;0;0]; end
Ltarget=Ltarget(:); q=q0(:);
if numel(Ltarget)~=3 || any(~isfinite(Ltarget)) || any(Ltarget<=0)
 error('ghe3:fk','Lengths must be positive finite values.');
end
if numel(q)~=3 || any(~isfinite(q)) || q(1)<=0 || any(abs(q(2:3))>=pi/2)
 error('ghe3:fk','Initial pose must have h>0 and angles strictly inside +/-90 deg.');
end
S=diag([p.rp 1 1]); tolerance=1e-10; converged=false; it=0;
for it=1:80
 [L,J]=ghe3_geometry(q,p); res=L-Ltarget;
 if norm(res,inf)<tolerance, converged=true; break; end
 A=J*S; [U,D,V]=svd(A); sd=diag(D);
 damping=max(1e-10,1e-5*max(sd));
 dx=-V*((sd./(sd.^2+damping^2)).*(U'*res));
 if norm(dx)>0.3, dx=dx*(0.3/norm(dx)); end
 accepted=false;
 for ls=0:16
  candidate=q+S*dx*2^(-ls);
  if candidate(1)<=0 || any(abs(candidate(2:3))>=pi/2-1e-5), continue; end
  Lnew=ghe3_geometry(candidate,p);
  if norm(Lnew-Ltarget)<norm(res)
   q=candidate; accepted=true; break;
  end
 end
 if ~accepted, break; end
end
[L,~,g]=ghe3_geometry(q,p);
converged=norm(L-Ltarget,inf)<tolerance;
info=struct('converged',converged,'iterations',it,'residual',norm(L-Ltarget,inf), ...
 'condition',g.condition,'localBranchOnly',true);
end
