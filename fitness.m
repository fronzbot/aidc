% Kevin Fronczak
% aidc
% fitness.m
% 2013.06.28

function [ fitValue ] = fitness( bee )
%This function places each system into the switched converter and evaluates
% the fitness value for each based on experimentally gathered data. 

% The following is for a ideal boost converter operating in DCM
boost = boostTF();

% Begin constructing each system and analyze the fitness
controller = bee.gm*bee.Gro*bee.Grb/(bee.Grt + bee.Grb)*tf(bee.Gzc, bee.Gpc);
system = boost*controller;

% Weighted coefficients for parameters
% [tr, ts, os, pm, gain]
W = [1e-4, 1e-3, 100, 30, 1];

% Get step information and freqeuency response information
stepvals = stepinfo(system);

tr = stepvals.RiseTime;
ts = stepvals.SettlingTime;
os = stepvals.Overshoot;

[~, pm] = margin(system);
gain    = dcgain(system);

% Prevent any "0" or NaN values
if os == 0 || isnan(os)
    os = Inf;
end
if tr == 0 || isnan(os)
    tr = Inf;
end
if ts == 0 || isnan(os)
    ts = Inf;
end
if pm == Inf || isnan(pm)
    pm = -180;
end


% Calculate penalties
penalty = 0;
if outsideRange(tr, 10e-9, 100e-6)
    penalty = penalty + 2*W(1)/abs(tr);
end
if outsideRange(ts, 10e-9, 10e-3)
    penalty = penalty + 2*W(2)/abs(ts);
end
if outsideRange(os, 0, 60)
    penalty = penalty + 2*W(3)/abs(os);
end
if outsideRange(pm, 45, 80)
    penalty = penalty + 2*W(4)*abs(pm);
end
if outsideRange(gain, 100, 10e3)
    penalty = penalty + 2*W(5)*abs(gain);
end


fitValue = ((W(1)*1/tr) + (W(2)*1/ts) + (W(3)*1/os) + (W(4)*pm) + (W(5)*gain)) - penalty;
if isnan(fitValue)
    fitValue = -1e5;
end
end


