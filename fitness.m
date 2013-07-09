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
% stepvals = stepinfo(feedback(system,1));
% 
% tr = stepvals.RiseTime;
% ts = stepvals.SettlingTime;
% os = stepvals.Overshoot;

[pm, gainMarg, gain, bw] = getFreqInfo(system);

% Prevent any invalid values
% if isnan(os)
%     os = 0;
% end
% if tr == 0 || isnan(tr)
%     tr = Inf;
% end
% if ts == 0 || isnan(ts)
%     ts = Inf;
% end
% if pm == Inf || isnan(pm)
%     pm = -180;
% end
% if gain == Inf || isnan(gain)
%     gain = -1e3;
% end
% if gainMarg == Inf || isnan(gainMarg)
%     gainMarg = -1e3;
% end


% Normalize all values
pm       = pm/180;
gain     = gain/100;
gainMarg = gainMarg/60; 
bw       = log(bw)/5;

% tr = 1e-5/tr;
% ts = 1e-4/ts;
% os = os/100;


% Create parabolas
f_pm = -(pm-60/180)^2+1;
f_g  = -(gain-60/100)^2+1;
f_gm = -(gainMarg-20/60)^2+1;
f_bw = -0.8*(bw-3.5/5)^2+1;
% f_tr = -((tr-1e-5/1e-6)^2+1)/100;
% f_ts = -(ts-1e-4/1e-3)^2+1;
% f_os = -(os-5/100)^2;

% Create penalties
% ptr = 0;
% pts = 0;
% if outsideRange(tr, 1e-7, 1e-4)
%     ptr = 10*abs(f_tr);
% end
% if outsideRange(ts, 1e-6, 1e-2)
%     pts = 10*abs(f_ts);
% end
% 
% penalty = ptr+pts;

% fitValue = (3*f_pm + f_g + f_gm + f_tr + f_ts + f_os) - penalty;
fitValue = 3*pm + f_g + f_gm + 1.8*f_bw;
if isnan(fitValue)
    fitValue = -1e15;
end
end


