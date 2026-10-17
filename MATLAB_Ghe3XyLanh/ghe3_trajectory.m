function [q,qd,qdd] = ghe3_trajectory(t,p)
% Periodic benchmark, phases chosen to exercise coupled roll and pitch.
% No start/stop ramp: do NOT command real hardware from this demonstration.
t=t(:); w=2*pi*p.frequency;
q=[p.h0+p.ampH*sin(w*t), p.ampRoll*sin(w*t+pi/2), p.ampPitch*sin(w*t)];
qd=[w*p.ampH*cos(w*t), w*p.ampRoll*cos(w*t+pi/2), w*p.ampPitch*cos(w*t)];
qdd=[-w*w*p.ampH*sin(w*t), -w*w*p.ampRoll*sin(w*t+pi/2), -w*w*p.ampPitch*sin(w*t)];
end
