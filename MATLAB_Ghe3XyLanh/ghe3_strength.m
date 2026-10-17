function s = ghe3_strength(p, results)
%GHE3_STRENGTH Preliminary strength checks for a three-cylinder seat.
%   S = GHE3_STRENGTH(P, RESULTS) uses SI units throughout. Positive cylinder
%   force is compression/extension support; negative force is tension.
%   RESULTS.forces and RESULTS.lengths are N-by-3; RESULTS.qdd(:,1) is the
%   vertical acceleration of the platform reference point, in m/s^2.
%   RESULTS.lateralForces is N-by-3: each 3-RPS leg's transverse constraint
%   reaction along its base revolute-joint axis. If absent, zero is assumed
%   only for compatibility and a missing-constraint-load warning is emitted.
%
%   These calculations are screening calculations, not a certification of
%   safety. Joint constraints, lateral loads, fatigue, frame load paths,
%   pneumatic transients and manufacturer ratings require separate checks.
%   The Euler calculation is reported only for sufficiently slender rods.

required = {'g','mass','loadFactor','nStrength','boreDiameter', ...
    'rodDiameter','pSupply','pExhaust','efficiency','friction', ...
    'rodE','rodFy','rodEccentricity','rodUnsupportedBase','rodK','Lmin', ...
    'pinDiameter','pinShearPlanes','pinBearingPlates', ...
    'pinPlateThickness','pinFy','pinPlateFy','cylinderWall','cylinderFy', ...
    'beamSpan','beamWidth','beamHeight','beamWall','beamFy'};
for k = 1:numel(required)
    name = required{k};
    if ~isfield(p,name) || ~isnumeric(p.(name)) || ...
            ~isscalar(p.(name)) || ~isreal(p.(name)) || ~isfinite(p.(name))
        error('ghe3_strength:parameter', ...
            'Parameter p.%s must be a finite real scalar in SI units.',name);
    end
end
positive = {'g','mass','boreDiameter','rodDiameter','pSupply','efficiency', ...
    'rodE','rodFy','rodUnsupportedBase','rodK','Lmin','pinDiameter', ...
    'pinShearPlanes','pinBearingPlates','pinPlateThickness','pinFy', ...
    'pinPlateFy','cylinderWall','cylinderFy','beamSpan','beamWidth', ...
    'beamHeight','beamWall','beamFy'};
for k = 1:numel(positive)
    if p.(positive{k}) <= 0
        error('ghe3_strength:parameter','Parameter p.%s must be positive.',positive{k});
    end
end
if p.loadFactor < 1 || p.nStrength < 1
    error('ghe3_strength:safetyFactor','loadFactor and nStrength must be at least 1.');
end
if p.efficiency > 1 || p.pExhaust < 0 || p.friction < 0 || p.rodEccentricity < 0
    error('ghe3_strength:parameter', ...
        'Require efficiency <= 1 and nonnegative exhaust gauge pressure, friction and eccentricity.');
end
if p.rodDiameter >= p.boreDiameter
    error('ghe3_strength:geometry','rodDiameter must be smaller than boreDiameter.');
end
if 2*p.beamWall >= min(p.beamWidth,p.beamHeight)
    error('ghe3_strength:geometry','RHS beam wall must leave a positive inner section.');
end
if any([p.pinShearPlanes,p.pinBearingPlates] ~= ...
        round([p.pinShearPlanes,p.pinBearingPlates]))
    error('ghe3_strength:geometry','Pin shear planes and bearing plates must be positive integers.');
end
names = {'forces','lengths','qdd'};
for k = 1:numel(names)
    name = names{k};
    if ~isfield(results,name)
        error('ghe3_strength:results','results.%s is required.',name);
    end
    value = results.(name);
    if ~isnumeric(value) || ~isreal(value) || isempty(value) || ...
            size(value,2) ~= 3 || any(~isfinite(value(:)))
        error('ghe3_strength:results','results.%s must be a finite real N-by-3 array.',name);
    end
end
if size(results.forces,1) ~= size(results.lengths,1) || ...
        size(results.forces,1) ~= size(results.qdd,1)
    error('ghe3_strength:results','forces, lengths and qdd must have the same row count.');
end
lateralForcesProvided = isfield(results,'lateralForces');
if lateralForcesProvided
    transverse = results.lateralForces;
    if ~isnumeric(transverse) || ~isreal(transverse) || ...
            ~isequal(size(transverse),size(results.forces)) || ...
            any(~isfinite(transverse(:)))
        error('ghe3_strength:results', ...
            'results.lateralForces must be a finite real array matching results.forces.');
    end
else
    transverse = zeros(size(results.forces));
end

s.units = 'SI: N, m, Pa, kg, s';
s.scope = 'PRELIMINARY SCREENING ONLY; not a declaration of safety';
s.loadFactor = p.loadFactor;
s.materialSafetyFactor = p.nStrength;
s.design.compression = p.loadFactor*max(max(results.forces,[],1),0);
s.design.tension = p.loadFactor*max(-min(results.forces,[],1),0);
s.design.absolute = max(s.design.compression,s.design.tension);
s.design.jointResultant = p.loadFactor*max(hypot(results.forces,transverse),[],1);
s.constraint.lateralForcesProvided = lateralForcesProvided;
s.constraint.designTransverseForce = p.loadFactor*max(abs(transverse),[],1);
s.constraint.sideLoadRatingAssessed = false;
s.constraint.status = 'NOT ASSESSED: manufacturer cylinder side-load and guide-bearing ratings';
s.constraint.note = ['3-RPS transverse constraint reactions are included in pin ', ...
    'resultants and a conservative exposed-rod bending screen. The actual ', ...
    'rod/tube/piston-bearing load distribution and manufacturer side-load ', ...
    'limits have NOT been assessed.'];

% Gauge pressures refer to ambient; atmospheric pressure cancels in the
% net actuator thrust when both chamber pressures use the same reference.
A = pi*p.boreDiameter^2/4;
Ar = pi*p.rodDiameter^2/4;
Aann = A-Ar;
s.pneumatic.pistonArea = A;
s.pneumatic.annularArea = Aann;
s.pneumatic.pressureReference = 'gauge, relative to the same ambient pressure';
s.pneumatic.extensionCapacity = ...
    p.efficiency*(p.pSupply*A-p.pExhaust*Aann)-p.friction;
s.pneumatic.retractionCapacity = ...
    p.efficiency*(p.pSupply*Aann-p.pExhaust*A)-p.friction;
s.pneumatic.extensionUtilization = ...
    capacity_ratio(s.design.compression,s.pneumatic.extensionCapacity);
s.pneumatic.retractionUtilization = ...
    capacity_ratio(s.design.tension,s.pneumatic.retractionCapacity);
s.pneumatic.pass = s.pneumatic.extensionUtilization <= 1 & ...
    s.pneumatic.retractionUtilization <= 1;
s.pneumatic.status = check_label(s.pneumatic.pass);
s.pneumatic.note = ['Ideal chamber-pressure thrust reduced by stated efficiency ', ...
    'and friction; check valve flow, dynamic chamber pressures and maker ratings.'];

% Rod stress: time-synchronous envelope of axial stress plus first-order
% bending. Conservatively place the full transverse constraint reaction at
% the tip of the exposed rod, idealized as a cantilever of length Le.
% Actual cylinder bearings can distribute this load differently; the model
% does not establish allowable side loading or beam-column amplification.
Ir = pi*p.rodDiameter^4/64;
Zr = pi*p.rodDiameter^3/32;
unsupportedHistory = p.rodUnsupportedBase+max(results.lengths-p.Lmin,0);
eccentricMomentHistory = abs(results.forces)*p.rodEccentricity;
lateralMomentHistory = abs(transverse).*unsupportedHistory;
bendingMomentHistory = eccentricMomentHistory+lateralMomentHistory;
s.rod.area = Ar;
s.rod.secondMoment = Ir;
s.rod.sectionModulus = Zr;
s.rod.axialStress = s.design.absolute/Ar;
s.rod.eccentricBendingMomentDesign = p.loadFactor*max(eccentricMomentHistory,[],1);
s.rod.lateralBendingMomentDesign = p.loadFactor*max(lateralMomentHistory,[],1);
s.rod.bendingMomentDesign = p.loadFactor*max(bendingMomentHistory,[],1);
s.rod.bendingStress = s.rod.bendingMomentDesign/Zr;
s.rod.combinedStress = p.loadFactor*max( ...
    abs(results.forces)/Ar+bendingMomentHistory/Zr,[],1);
s.rod.allowableStress = p.rodFy/p.nStrength;
s.rod.yieldMargin = positive_ratio(p.rodFy,p.nStrength*s.rod.combinedStress);
s.rod.yieldPass = s.rod.yieldMargin >= 1;
s.rod.yieldStatus = check_label(s.rod.yieldPass);
s.rod.stressModel = ['Time-envelope axial + eccentric bending + transverse ', ...
    'end-load cantilever bending on the full exposed rod; first-order only. ', ...
    'Actual cylinder side-load/guide-bearing capacity is NOT validated.'];

strokeExtension = max(max(results.lengths-p.Lmin,0),[],1);
s.rod.unsupportedLength = p.rodUnsupportedBase+strokeExtension;
s.rod.effectiveLength = p.rodK*s.rod.unsupportedLength;
s.rod.radiusOfGyration = sqrt(Ir/Ar);
s.rod.slenderness = s.rod.effectiveLength/s.rod.radiusOfGyration;
s.rod.eulerCriticalSlenderness = pi*sqrt(p.rodE/p.rodFy);
s.rod.eulerApplicable = s.rod.slenderness >= s.rod.eulerCriticalSlenderness;
s.rod.eulerCriticalLoad = NaN(1,3);
s.rod.bucklingMargin = NaN(1,3);
s.rod.designLoadOverEuler = NaN(1,3);
s.rod.bucklingPass = false(1,3);
s.rod.bucklingStatus = cell(1,3);
for i = 1:3
    if s.rod.eulerApplicable(i)
        Pe = pi^2*p.rodE*Ir/s.rod.effectiveLength(i)^2;
        s.rod.eulerCriticalLoad(i) = Pe;
        s.rod.bucklingMargin(i) = positive_ratio(Pe,p.nStrength*s.design.compression(i));
        s.rod.designLoadOverEuler(i) = s.design.compression(i)/Pe;
        s.rod.bucklingPass(i) = s.rod.bucklingMargin(i) >= 1;
        tmp = check_label(s.rod.bucklingPass(i));
        s.rod.bucklingStatus{i} = tmp{1};
    else
        s.rod.bucklingStatus{i} = 'NOT ASSESSED: Euler outside slender-rod applicability';
    end
end
s.rod.secondOrderRequired = s.rod.designLoadOverEuler > 0.3;
s.rod.bucklingNote = ['Euler is an ideal elastic column screen. The fy-based ', ...
    'slenderness boundary is approximate; verify proportional limit, end fixity, ', ...
    'manufacturer buckling data and inelastic/second-order behavior separately.'];

% A pin transmits the full joint force; the plate count is the count of
% equally loaded bearing plates, not automatically the number of shear planes.
s.pin.shearArea = p.pinShearPlanes*pi*p.pinDiameter^2/4;
s.pin.shearStress = s.design.jointResultant/s.pin.shearArea;
s.pin.allowableShearStress = p.pinFy/(sqrt(3)*p.nStrength);
s.pin.shearMargin = positive_ratio(s.pin.allowableShearStress,s.pin.shearStress);
s.pin.shearPass = s.pin.shearMargin >= 1;
s.pin.bearingArea = p.pinBearingPlates*p.pinDiameter*p.pinPlateThickness;
s.pin.bearingStress = s.design.jointResultant/s.pin.bearingArea;
s.pin.allowableBearingStress = p.pinPlateFy/p.nStrength;
s.pin.bearingMargin = positive_ratio(s.pin.allowableBearingStress,s.pin.bearingStress);
s.pin.bearingPass = s.pin.bearingMargin >= 1;
s.pin.status = check_label(s.pin.shearPass & s.pin.bearingPass);
s.pin.note = ['Uses joint resultant sqrt(axial^2 + transverse^2). Uniform ', ...
    'pure shear and projected bearing only; verify unequal plate loading, ', ...
    'pin bending, axial pin thrust, lug net section, edge tear-out and joint ratings.'];

% Lame solution at the inside of an ideal closed-end cylindrical wall.
% pSupply is gauge pressure; external gauge pressure is zero.
a = p.boreDiameter/2;
b = a+p.cylinderWall;
pressure = p.pSupply;
s.cylinder.innerRadius = a;
s.cylinder.outerRadius = b;
s.cylinder.designGaugePressure = pressure;
s.cylinder.radialStress = -pressure;
s.cylinder.hoopStress = pressure*(a^2+b^2)/(b^2-a^2);
s.cylinder.axialStress = pressure*a^2/(b^2-a^2);
sr = s.cylinder.radialStress;
st = s.cylinder.hoopStress;
sz = s.cylinder.axialStress;
s.cylinder.vonMisesStress = sqrt(((st-sr)^2+(sr-sz)^2+(sz-st)^2)/2);
s.cylinder.allowableStress = p.cylinderFy/p.nStrength;
s.cylinder.yieldMargin = positive_ratio(s.cylinder.allowableStress,s.cylinder.vonMisesStress);
s.cylinder.pass = s.cylinder.yieldMargin >= 1;
s.cylinder.status = check_label(s.cylinder.pass);
s.cylinder.enteredPressureRating = NaN;
s.cylinder.pressureRatingUtilization = NaN;
s.cylinder.pressureRatingPass = false;
s.cylinder.pressureRatingStatus = 'NOT ASSESSED: manufacturer pressure rating missing';
if isfield(p,'ratedPressure') && isnumeric(p.ratedPressure) && ...
        isscalar(p.ratedPressure) && isreal(p.ratedPressure) && ...
        isfinite(p.ratedPressure) && p.ratedPressure > 0
    s.cylinder.enteredPressureRating = p.ratedPressure;
    s.cylinder.pressureRatingUtilization = p.pSupply/p.ratedPressure;
    s.cylinder.pressureRatingPass = s.cylinder.pressureRatingUtilization <= 1;
    ratingLabel = check_label(s.cylinder.pressureRatingPass);
    s.cylinder.pressureRatingStatus = ratingLabel{1};
end
s.cylinder.note = ['Ideal closed-end wall at supply gauge pressure only; ', ...
    'check pressure peaks, caps, threads, seals, ports and certified maker pressure rating. ', ...
    'Any example rating must be replaced by the actual manufacturer rating.'];

% One illustrative simply-supported RHS beam carrying a centered point
% load. This is not a representation of a complete triangular frame.
B = p.beamWidth;
H = p.beamHeight;
t = p.beamWall;
s.beam.model = 'SINGLE SIMPLY-SUPPORTED RHS BEAM, CENTERED POINT LOAD';
s.beam.secondMoment = (B*H^3-(B-2*t)*(H-2*t)^3)/12;
s.beam.sectionModulus = 2*s.beam.secondMoment/H;
s.beam.designPointLoad = p.loadFactor*max(abs(p.mass*(p.g+results.qdd(:,1))));
s.beam.bendingMoment = s.beam.designPointLoad*p.beamSpan/4;
s.beam.bendingStress = s.beam.bendingMoment/s.beam.sectionModulus;
s.beam.allowableStress = p.beamFy/p.nStrength;
s.beam.yieldMargin = positive_ratio(s.beam.allowableStress,s.beam.bendingStress);
s.beam.pass = s.beam.yieldMargin >= 1;
s.beam.status = check_label(s.beam.pass);
s.beam.centerDeflection = NaN;
if isfield(p,'beamE') && isnumeric(p.beamE) && isscalar(p.beamE) && ...
        isreal(p.beamE) && isfinite(p.beamE) && p.beamE > 0
    s.beam.centerDeflection = s.beam.designPointLoad*p.beamSpan^3/ ...
        (48*p.beamE*s.beam.secondMoment);
end
s.beam.note = ['Illustrative beam bending only. No pass claim for the whole ', ...
    'frame; real support positions, eccentric loads, torsion, welds, local ', ...
    'buckling and deflection limits require a structural model.'];

s.unassessed = {'Actual joint-axis alignment and distribution of constraint loads', ...
    'Cylinder manufacturer side-load and rod/tube/piston guide-bearing capacities', ...
    'Manufacturer force, pressure, side-load and speed ratings', ...
    'Global three-dimensional frame, joints, welds and foundations', ...
    'Fatigue life and stress concentration', ...
    'Pneumatic compressibility, valve flow and pressure transients', ...
    'Failure of supply, hose or valve; mechanical restraints and emergency stop'};
s.warnings = {s.constraint.note,s.pneumatic.note,s.rod.stressModel,s.rod.bucklingNote, ...
    s.pin.note,s.cylinder.note,s.beam.note};
if ~lateralForcesProvided
    s.warnings{end+1} = ['results.lateralForces missing: transverse forces ', ...
        'were set to zero for legacy compatibility; actual 3-RPS side-load ', ...
        'and joint-resultant demands remain unassessed.'];
end
if any(~s.rod.eulerApplicable)
    s.warnings{end+1} = ['Some rods are outside Euler applicability: buckling ', ...
        'has NOT been assessed; use an appropriate inelastic method or maker data.'];
end
if any(s.rod.secondOrderRequired)
    s.warnings{end+1} = ['Design compression exceeds 0.3 of Euler load in at ', ...
        'least one rod: nonlinear second-order beam-column analysis is required.'];
end
if any(any(results.lengths < p.Lmin))
    s.warnings{end+1} = 'Some computed cylinder lengths are below Lmin; check stroke feasibility.';
end
if p.pExhaust > p.pSupply
    s.warnings{end+1} = 'Exhaust gauge pressure exceeds supply pressure; verify pressure inputs.';
end
s.numericChecksPass = all(s.pneumatic.pass) && all(s.rod.yieldPass) && ...
    all(s.rod.bucklingPass) && all(s.pin.shearPass) && ...
    all(s.pin.bearingPass) && s.cylinder.pass && ...
    s.cylinder.pressureRatingPass && s.beam.pass;
assessedLimitExceeded = ~all(s.pneumatic.pass) || ~all(s.rod.yieldPass) || ...
    any(s.rod.eulerApplicable & ~s.rod.bucklingPass) || ...
    ~all(s.pin.shearPass) || ~all(s.pin.bearingPass) || ...
    ~s.cylinder.pass || ~s.beam.pass || ...
    (isfinite(s.cylinder.pressureRatingUtilization) && ~s.cylinder.pressureRatingPass);
if assessedLimitExceeded
    s.status = 'SCREENING LIMIT EXCEEDED: inspect individual checks; critical checks remain';
elseif ~all(s.rod.eulerApplicable)
    s.status = 'SCREENING INCOMPLETE: rod buckling not assessed; other critical checks remain';
elseif ~isfinite(s.cylinder.pressureRatingUtilization)
    s.status = 'SCREENING INCOMPLETE: manufacturer pressure rating missing; critical checks remain';
elseif any(s.rod.secondOrderRequired)
    s.status = 'SCREENING INCOMPLETE: second-order rod analysis required; critical checks remain';
else
    s.status = 'NUMERIC SCREENS WITHIN LIMITS: manufacturer, global frame and fatigue checks remain';
end
end

function ratio = positive_ratio(numerator,denominator)
% Zero demand has infinite margin; this is not an unassessed-result marker.
ratio = numerator./denominator;
ratio(denominator == 0) = Inf;
end

function ratio = capacity_ratio(demand,capacity)
% A nonpositive actuator capacity must never appear as a passing ratio.
if capacity <= 0
    ratio = Inf(size(demand));
else
    ratio = demand/capacity;
end
end

function labels = check_label(pass)
labels = cell(size(pass));
for j = 1:numel(pass)
    if pass(j)
        labels{j} = 'WITHIN THIS NUMERIC SCREEN';
    else
        labels{j} = 'EXCEEDS THIS NUMERIC SCREEN';
    end
end
end
