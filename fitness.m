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
%W = [1e-4, 1e-3, 100, 30, 1];

% Get step information and freqeuency response information
stepvals = stepinfo(system);

tr = stepvals.RiseTime;
ts = stepvals.SettlingTime;
os = stepvals.Overshoot;

[~, pm] = margin(system);
gain    = dcgain(system);

% Prevent any invalid values
if isnan(os)
    os = 0;
end
if tr == 0 || isnan(tr)
    tr = Inf;
end
if ts == 0 || isnan(ts)
    ts = Inf;
end
if pm == Inf || isnan(pm)
    pm = -180;
end
if gain == Inf || isnan(gain)
    gain = -100;
end

% Calculate parameters based on parabolic equation
f_pm = -(pm-76)^2+1000;
f_g  = -(gain-60)^2+1000;
f_tr = -1e7*(tr-1e-6)^2+500;
f_ts = -1e9*(ts-1e-4)^2+500;
f_os = -5*os^2 + 1000;

% Calculate penalties
penalty = 0;
if outsideRange(tr, 10e-9, 100e-6)
    penalty = penalty + 2*abs(f_tr);
end
if outsideRange(ts, 10e-9, 10e-3)
    penalty = penalty + 2*abs(f_ts);
end
if outsideRange(os, 0, 60)
    penalty = penalty + 2*abs(f_os);
end
if outsideRange(pm, 45, 80)
    penalty = penalty + 2*abs(f_pm);
end
if outsideRange(gain, 500, 10e3)
    penalty = penalty + 2*abs(f_g);
end


fitValue = (f_pm + f_g + f_tr + f_ts + f_os) - penalty;
if isnan(fitValue)
    fitValue = -1e5;
end
end


