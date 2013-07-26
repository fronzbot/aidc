% Kevin Fronczak
% aidc
% psoFit.m
% 2013.07.12

function [fitVal] = psoFit(pBest, opts)
boost = boostTF(opts);

% Extract RB from RT val
pBest.RB = 1/3.583*pBest.RT;

gm = 0.1;

% Construct controller with gm = 0.1

controller = gm*pBest.Ro*pBest.RB/(pBest.RB+pBest.RT)*tf(pBest.zeroCoeffs(1:pBest.zeroCount), pBest.poleCoeffs(1:pBest.poleCount));
system = boost*controller;

[pm, gainMarg, gain, ~] = getFreqInfo(system);
stepdata = stepinfo(system);
ts = stepdata.SettlingTime;

% Normalize all values
if strcmpi(opts.mode, 'DCM')
    pm       = pm/50;
    gain     = gain/60;
    gainMarg = gainMarg/35;
elseif strcmpi(opts.mode, 'CCM')
    pm       = pm/45;
    gain     = gain/50;
    gainMarg = gainMarg/20;
end

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


fitVal = (3*f_pm + 2*f_g + 0.6*f_gm)-penalty;
end
















