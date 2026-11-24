function p = ghe3_defaults()
% GHE3_DEFAULTS Example values, NOT a certified chair design. All units SI.
% 3-RPS: bottom revolute axes tangent to base circle, upper spherical joints.
p.model = '3RPS_TANGENTIAL_BASE_REVOLUTE_UPPER_SPHERICAL';
p.frameBaseSide = 1.000; % Outer equilateral frame side, NOT an anchor radius.
p.frameBaseShape = 'EQUILATERAL_TRIANGLE_ASSUMED';
p.rb = 0.420; % Radius of the three lower CA pivot centers.
p.rp = 0.360; % ASSUMED upper eye/CA center radius; side sqrt(3)*rp.
p.layoutNote = 'Upper anchor radius 360 mm assumed; verify plate, CA and eye geometry.';
p.baseAngle = 0; p.platformAngle = 0;
p.legAngles = pi-(0:2)*2*pi/3; % Rear 1, front-left 2, front-right 3.
p.stroke = 0.500; p.Lmin = 0.731; % CA + eye + 20 mm thread engagement: verify.
p.h0 = sqrt((p.Lmin+p.stroke/2)^2-(p.rb-p.rp)^2);
p.massPerson = 100; p.massSeat = 20; p.mass = 120; p.g = 9.81;
p.com = [0;0;100*0.250/120]; % Seat COM assumed at attachment plane.
p.inertia = diag([10 12 8]); % Assumed, not identified from the new mass/CAD.
p.Fexternal = [0;0;0]; p.Mexternal = [0;0;0]; % World frame, applied at COM.
p.ampH = 0.02; p.ampRoll = 4*pi/180; p.ampPitch = 4*pi/180;
p.frequency = 0.09; p.duration = 2/p.frequency; p.dt = 0.02;
p.boreDiameter = 0.063; p.rodDiameter = 0.020;
p.pSupply = 0.30e6; p.regulatorPressure = p.pSupply; % 3 bar gauge.
p.pExhaust = 0.05e6; p.pAtm = 101325;
p.ratedPressure = 1.00e6; % SC series rating; verify the installed assembly.
p.efficiency = 0.85; p.friction = 30; p.maxSpeed = 0.04;
p.maxJointAngle = 15*pi/180; p.maxPoseAngle = 15*pi/180;
p.maxCondition = 100; p.loadFactor = 1.30; p.nStrength = 2;
p.rodE = 210e9; p.rodFy = 355e6; p.rodEccentricity = 0.0005;
p.rodUnsupportedBase = 0.08; p.rodK = 1;
p.pinDiameter = 0.014; p.pinShearPlanes = 2; p.pinFy = 355e6;
p.pinPlateThickness = 0.008; p.pinBearingPlates = 2; p.pinPlateFy = 355e6;
p.cylinderWall = 0.005; p.cylinderFy = 250e6;
p.beamSpan = 1.0; p.beamWidth = 0.06; p.beamHeight = 0.08;
p.beamWall = 0.004; p.beamFy = 235e6; p.beamE=200e9;
p.workspaceSamples = 9;
% 5/3 closed-center + PA-12L. Valve flow/rating and compressor duty are
% illustrative inputs, not an identified catalogue curve or duty approval.
p = ghe3_air_defaults(p);
p = ghe3_validate(p);
end
