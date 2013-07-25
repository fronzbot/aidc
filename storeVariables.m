% Kevin Fronczak
% aidc
% storeVariables.m
% 2013.06.28

function [] = storeVariables( iter, bee, opts )
% The following is for a ideal boost converter operating in DCM
boost = boostTF(opts);

% Begin constructing each system and analyze the fitness
controller = bee.gm*bee.Gro*bee.Grb/(bee.Grt + bee.Grb)*tf(bee.Gzc, bee.Gpc);
system = boost*controller;

stepvals = stepinfo(system);

tr = stepvals.RiseTime;
ts = stepvals.SettlingTime;
os = stepvals.Overshoot;

[~, pm] = margin(system);
gain    = dcgain(system);

fit = fitness(bee, opts);

if isnan(os)
    os = Inf;
end
if isnan(os)
    tr = Inf;
end
if isnan(os)
    ts = Inf;
end

m = [iter fit tr ts os pm gain];
dlmwrite('data.csv', m, 'delimiter', ',', '-append');

end