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
stepvals = stepinfo(feedback(system,1));

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
    gain = -1e3;
end

% Calculate parameters based on parabolic equation
% f_pm = -0.8*(pm-76)^2+1000;
% f_g  = -(gain-6000)^2+500;
% if tr >= 1e-6
%     f_tr = -5e9*(tr-1e-6)^2+1000;
% else
%     f_tr = 2e9*tr-1000;
% end
% if ts >= 100e-6
%     f_ts = -5e8*(ts-100e-6)^2+1000;
% else
%     f_ts = 2e9*ts-1000;
% end
% 
% f_os = -5*os^2 + 1000;
% 
% % Calculate penalties
% penalty = 0;
% if outsideRange(tr, 10e-9, 100e-6)
%     if tr > 100e-6
%         penalty = penalty + 2*1e7*tr;
%     elseif tr < 10e-9
%         penalty = penalty + 2/tr;
%     end
% end
% if outsideRange(ts, 10e-9, 10e-3)
%     if ts > 10e-3
%         penalty = penalty + 2*1e6*ts;
%     elseif ts < 10e-9
%         penalty = penalty + 2/ts;
%     end
% end
% if outsideRange(os, 0, 60)
%     penalty = penalty + 2*abs(f_os);
% end
% if outsideRange(pm, 50, 85)
%     if pm > 85
%         penalty = penalty + 2e3*abs(pm);
%     elseif pm < 50
%         penalty = penalty + 2e3*1/abs(pm);
%     end
% end
% if outsideRange(gain, 100, 10e3)
%     if gain > 10e3
%         penalty = penalty + 2*gain;
%     elseif gain < 100 && gain > 0
%         penalty = penalty + 500*1/gain;
%     else
%         penalty = penalty + 100*abs(gain);
%     end
% end

% Normalize all values
pm = pm/180;
gain = gain/1e4;
tr = 1e-5/tr;
ts = 1e-4/ts;
os = os/100;

% Create penalties
ptr = 0;
pts = 0;
if outsideRange(tr, 1e-7, 1e-4)
    ptr = 10*tr;
end
if outsideRange(ts, 1e-6, 1e-2)
    pts = 10*ts;
end

penalty = ptr+pts;

% Create parabolas
f_pm = -(pm-70/180)^2+100;
f_g  = -(gain-5e3/1e4)^2+100;
f_tr = -(tr-1e-5/1e-6)^2+100;
f_ts = -(ts-1e-4/5e-3)^2+100;
f_os = -(os-5/100)^2+100;

fitValue = (1.5*f_pm + 1.3*f_g + 0.7*f_tr + 1.6*f_ts + f_os) - penalty;

if isnan(fitValue)
    fitValue = -1e15;
end
end


