% Kevin Fronczak
% aidc
% psoFit.m
% 2013.07.12

function [fitVal] = psoFit(pBest)
boost = boostTF();

% Extract RB from RT val
pBest.RB = 1/3.583*pBest.RT;

gm = 0.1;

% Construct controller with gm = 0.1

controller = gm*pBest.Ro*pBest.RB/(pBest.RB+pBest.RT)*tf(pBest.zeroCoeffs(1:pBest.zeroCount), pBest.poleCoeffs(1:pBest.poleCount));
system = boost*controller;

[pm, gainMarg, gain, bw] = getFreqInfo(system);

% Normalize all values
pm       = pm/70;
gain     = gain/60;
gainMarg = gainMarg/40; 
bw       = bw/2e3;


penalty = 0;

if outsideRange(gain, 0.3, 1.2)
    penalty = penalty + 2*max(1, abs(gain));
end
if outsideRange(pm, 0.3, 1.2)
    penalty = penalty + 2*max(1, abs(pm));
end
if outsideRange(gainMarg, 0.5, 1.2)
    penalty = penalty + 2*max(1, abs(gainMarg));
end
if outsideRange(bw, 0.3, 1.2)
    penalty = penalty + 4*max(1, abs(bw));
end

% Create parabolas
f_pm = -(pm-1)^2+1;
f_g  = -(gain-1)^2+1;
f_gm = -(gainMarg-1)^2+1;
f_bw = -(bw-1)^2+1;

fitVal = (3*f_pm + 2*f_g + 0.6*f_gm + 1.8*f_bw)-penalty;
end
















