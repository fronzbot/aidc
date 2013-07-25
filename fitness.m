% Kevin Fronczak
% aidc
% fitness.m
% 2013.06.28

function [ fitValue ] = fitness( bee, opts )
%This function places each system into the switched converter and evaluates
% the fitness value for each based on experimentally gathered data. 

% The following is for a ideal boost converter operating in DCM
boost = boostTF(opts);

% Begin constructing each system and analyze the fitness
controller = bee.gm*bee.Gro*bee.Grb/(bee.Grt + bee.Grb)*tf(bee.Gzc, bee.Gpc);
system = boost*controller;

[pm, gainMarg, gain, ~] = getFreqInfo(system);
stepdata = stepinfo(system);
ts = stepdata.SettlingTime;

% Normalize all values
pm       = pm/50;
gain     = gain/60;
gainMarg = gainMarg/35; 

penalty = 0;

if outsideRange(gain, 0.8, 1.2)
    penalty = penalty + 3*max(1, abs(gain));
end
if outsideRange(pm, 0.6, 1.2)
    penalty = penalty + 3*max(1, abs(pm));
end
if outsideRange(gainMarg, 0.5, 1.2)
    penalty = penalty + 2*max(1, abs(gainMarg));
end
if ts > 0.1 || isnan(ts)
    penalty = penalty + 2*max(2,abs(ts));
end



% Create parabolas
f_pm = -(pm-1)^2+1;
f_g  = -(gain-1)^2+1;
f_gm = -(gainMarg-1)^2+1;


fitValue = (3*f_pm + 2*f_g + 0.6*f_gm)-penalty;

end


