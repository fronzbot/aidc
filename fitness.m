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

[pm, gainMarg, gain, ~] = getFreqInfo(system);

% Normalize all values
pm       = pm/70;
gain     = gain/70;
gainMarg = gainMarg/40; 

penalty = 0;

if outsideRange(gain, 0.9, 1.4)
    penalty = penalty + 3*max(1, abs(gain));
end
if outsideRange(pm, 0.3, 1.2)
    penalty = penalty + 3*max(1, abs(pm));
end
if outsideRange(gainMarg, 0.5, 1.1)
    penalty = penalty + 2*max(1, abs(gainMarg));
end


% Create parabolas
f_pm = -(pm-1)^2+1;
f_g  = -(gain-1)^2+1;
f_gm = -(gainMarg-1)^2+1;


fitValue = (3*f_pm + 2*f_g + 0.6*f_gm)-penalty;

end


