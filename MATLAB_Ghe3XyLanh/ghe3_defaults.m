function p = ghe3_defaults()
% GHE3_DEFAULTS Example values, NOT a certified chair design. All units SI.
% 3-RPS: bottom revolute axes tangent to base circle, upper spherical joints.
p.model = '3RPS_TANGENTIAL_BASE_REVOLUTE_UPPER_SPHERICAL';
p.rb = 0.42; p.rp = 0.36; p.baseAngle = 0; p.platformAngle = 0;
p.h0 = 0.48; p.Lmin = 0.38; p.stroke = 0.20;
p.massPerson = 90; p.massSeat = 45; p.mass = 135; p.g = 9.81;
p.com = [0;0;0.30]; p.inertia = diag([10 12 8]); % About combined COM, body axes.
p.Fexternal = [0;0;0]; p.Mexternal = [0;0;0]; % World frame, applied at COM.
p.ampH = 0.02; p.ampRoll = 4*pi/180; p.ampPitch = 4*pi/180;
p.frequency = 0.30; p.duration = 8; p.dt = 0.02;
p.boreDiameter = 0.063; p.rodDiameter = 0.025;
p.pSupply = 0.60e6; p.pExhaust = 0.05e6; p.pAtm = 101325;
p.ratedPressure = 0.80e6; % Placeholder catalog limit; replace from actual datasheet.
p.efficiency = 0.85; p.friction = 30; p.maxSpeed = 0.20;
p.maxJointAngle = 20*pi/180; p.maxPoseAngle = 20*pi/180;
p.maxCondition = 100; p.loadFactor = 1.30; p.nStrength = 2;
p.rodE = 210e9; p.rodFy = 355e6; p.rodEccentricity = 0.0005;
p.rodUnsupportedBase = 0.08; p.rodK = 1;
p.pinDiameter = 0.016; p.pinShearPlanes = 2; p.pinFy = 355e6;
p.pinPlateThickness = 0.008; p.pinBearingPlates = 2; p.pinPlateFy = 355e6;
p.cylinderWall = 0.005; p.cylinderFy = 250e6;
p.beamSpan = 0.8; p.beamWidth = 0.06; p.beamHeight = 0.08;
p.beamWall = 0.004; p.beamFy = 235e6; p.beamE=210e9;
p.workspaceSamples = 9;
p = ghe3_validate(p);
end
