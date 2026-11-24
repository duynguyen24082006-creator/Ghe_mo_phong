function p = ghe3_validate(p)
% Validate parameters without silently clipping unsafe/meaningless values.
p=ghe3_air_defaults(p);
if isfield(p,'frameBaseSide')
 v=p.frameBaseSide;
 if ~isnumeric(v)||~isscalar(v)||~isreal(v)||~isfinite(v)||v<=0
  error('ghe3:frame','frameBaseSide must be finite and positive.');
 end
 if isfield(p,'frameBaseShape') && strcmp(p.frameBaseShape,'EQUILATERAL_TRIANGLE_ASSUMED') ...
   && p.rb>v/sqrt(3)
  error('ghe3:frame','Lower anchor centers lie outside the aligned outer triangle.');
 end
end
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
airPositive={'valveRatedFlowLpm','valveRatedInletPressure', ...
 'valveRatedPressureDrop','valveMaxPressureDrop','valveMaxTrackingError', ...
 'tankVolume','tankPressureMax','tankPressureCutIn','regulatorPressure','airTimeStep'};
airNonnegative={'valveDeadbandSpeed','valveResponseTime','compressorFlowLpm', ...
 'tankInitialPressure','regulatorHeadroom'};
for k=1:numel(airPositive)
 v=p.(airPositive{k});
 if ~isnumeric(v)||~isscalar(v)||~isreal(v)||~isfinite(v)||v<=0
  error('ghe3:airParameter','%s must be a finite positive scalar.',airPositive{k});
 end
end
for k=1:numel(airNonnegative)
 v=p.(airNonnegative{k});
 if ~isnumeric(v)||~isscalar(v)||~isreal(v)||~isfinite(v)||v<0
  error('ghe3:airParameter','%s must be a finite nonnegative scalar.',airNonnegative{k});
 end
end
if ~ischar(p.valveType)||~strcmp(p.valveType,'5/3_CLOSED_CENTER')
 error('ghe3:valveType','Supported valveType is 5/3_CLOSED_CENTER.');
end
if ~isnumeric(p.valveCriticalRatio)||~isscalar(p.valveCriticalRatio)|| ...
 ~isreal(p.valveCriticalRatio)||~isfinite(p.valveCriticalRatio)|| ...
 p.valveCriticalRatio<=0||p.valveCriticalRatio>=1
 error('ghe3:airParameter','valveCriticalRatio must lie strictly in (0,1).');
end
if ~isnumeric(p.compressorMaxDuty)||~isscalar(p.compressorMaxDuty)|| ...
 ~isreal(p.compressorMaxDuty)||~isfinite(p.compressorMaxDuty)|| ...
 p.compressorMaxDuty<=0||p.compressorMaxDuty>1
 error('ghe3:airParameter','compressorMaxDuty must lie in (0,1].');
end
if p.tankPressureCutIn>=p.tankPressureMax||p.tankInitialPressure>p.tankPressureMax
 error('ghe3:airParameter','Require cut-in < cut-out and initial pressure <= cut-out.');
end
if p.valveRatedPressureDrop>=p.valveRatedInletPressure
 error('ghe3:airParameter','Valve reference outlet gauge pressure must be positive.');
end
for name={'computeWorkspace','computeFK'}
 v=p.(name{1});
 if ~(islogical(v)||isnumeric(v))||~isscalar(v)||~isreal(v)||~isfinite(v)||~any(v==[0 1])
  error('ghe3:airParameter','%s must be logical true or false.',name{1});
 end
 p.(name{1})=logical(v);
end
if isfield(p,'legAngles')
 v=p.legAngles;
 if ~isnumeric(v)||numel(v)~=3||~isreal(v)||any(~isfinite(v(:)))
  error('ghe3:parameter','legAngles must contain three finite real angles.');
 end
 p.legAngles=reshape(v,1,3);
end
end
