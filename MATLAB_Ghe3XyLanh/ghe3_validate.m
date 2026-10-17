function p = ghe3_validate(p)
% Validate parameters without silently clipping unsafe/meaningless values.
positive = {'rb','rp','h0','Lmin','stroke','massSeat','g', ...
 'duration','dt','frequency','boreDiameter','rodDiameter','pSupply','pAtm', ...
 'ratedPressure','maxSpeed','maxJointAngle','maxPoseAngle','maxCondition','loadFactor', ...
 'nStrength','rodE','rodFy','rodUnsupportedBase','rodK','pinDiameter', ...
 'pinShearPlanes','pinFy','pinPlateThickness','pinBearingPlates', ...
 'pinPlateFy','cylinderWall','cylinderFy','beamSpan','beamWidth', ...
 'beamHeight','beamWall','beamFy','beamE','workspaceSamples'};
for k=1:numel(positive)
 v=p.(positive{k});
 if ~isnumeric(v) || ~isscalar(v) || ~isreal(v) || ~isfinite(v) || v<=0
  error('ghe3:parameter','%s must be a finite positive scalar.',positive{k});
 end
end
nonnegative={'massPerson','ampH','ampRoll','ampPitch','pExhaust','friction','rodEccentricity'};
for k=1:numel(nonnegative)
 v=p.(nonnegative{k});
 if ~isnumeric(v) || ~isscalar(v) || ~isreal(v) || ~isfinite(v) || v<0
  error('ghe3:parameter','%s must be finite and nonnegative.',nonnegative{k});
 end
end
if p.rodDiameter>=p.boreDiameter, error('ghe3:parameter','Rod must be smaller than bore.'); end
if p.loadFactor<1 || p.nStrength<1, error('ghe3:parameter','loadFactor and nStrength must be at least 1.'); end
if p.pSupply<=p.pExhaust, error('ghe3:parameter','Supply gauge pressure must exceed exhaust.'); end
if p.efficiency<=0 || p.efficiency>1 || ~isfinite(p.efficiency)
 error('ghe3:parameter','efficiency must be in (0,1].');
end
if 2*p.beamWall>=min(p.beamWidth,p.beamHeight)
 error('ghe3:parameter','RHS beam wall must be less than half each external dimension.');
end
if p.maxJointAngle>=pi/2 || p.maxPoseAngle>=pi/2
 error('ghe3:parameter','Angular limits must be below 90 degrees.');
end
if p.ampRoll>p.maxPoseAngle || p.ampPitch>p.maxPoseAngle || p.h0<=p.ampH
 error('ghe3:parameter','Trajectory exceeds pose limits or crosses h=0.');
end
if p.dt>p.duration || p.dt>1/(20*p.frequency)
 error('ghe3:parameter','dt must resolve a cycle by at least 20 samples.');
end
if p.workspaceSamples~=round(p.workspaceSamples) || p.workspaceSamples<3 || p.workspaceSamples>41
 error('ghe3:parameter','workspaceSamples must be an integer from 3 to 41.');
end
if p.pinShearPlanes~=round(p.pinShearPlanes) || p.pinBearingPlates~=round(p.pinBearingPlates)
 error('ghe3:parameter','Pin plane and bearing plate counts must be integers.');
end
vectors={'com','Fexternal','Mexternal'};
for k=1:numel(vectors)
 v=p.(vectors{k});
 if ~isnumeric(v) || numel(v)~=3 || ~isreal(v) || any(~isfinite(v(:)))
  error('ghe3:parameter','%s must have three finite real entries.',vectors{k});
 end
 p.(vectors{k})=v(:);
end
I=p.inertia;
if ~isnumeric(I) || ~isequal(size(I),[3 3]) || ~isreal(I) || any(~isfinite(I(:))) || norm(I-I','fro')>1e-10*max(norm(I,'fro'),1)
 error('ghe3:parameter','inertia must be a finite symmetric 3x3 tensor at COM.');
end
ev=eig((I+I')/2);
if any(ev<=0) || max(ev)>sum(ev)-max(ev)+1e-10*max(ev)
 error('ghe3:parameter','Inertia must be positive definite and satisfy principal-moment triangle inequalities.');
end
if ~isscalar(p.baseAngle)||~isfinite(p.baseAngle)||~isscalar(p.platformAngle)||~isfinite(p.platformAngle)
 error('ghe3:parameter','Triangle angle offsets must be finite scalars.');
end
p.mass=p.massPerson+p.massSeat;
end
