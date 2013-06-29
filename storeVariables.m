% Kevin Fronczak
% aidc
% storeVariables.m
% 2013.06.28

function [] = storeVariables( iter, bee )
% The following is for a ideal boost converter operating in DCM
boost = boostTF();

% Begin constructing each system and analyze the fitness
controller = bee.gm*bee.Gro*bee.Grb/(bee.Grt + bee.Grb)*tf(bee.Gzc, bee.Gpc);
system = boost*controller;

Pfb = bee.Vo^2/(bee.Grb+bee.Grt);    % Power
[gain, phase] = bode(system);  
magdbsq = squeeze(20*log10(gain(1,1,:)));
phasesq = squeeze(phase(1,1,:));
[Gol, Pm] = findPM(magdbsq, phasesq);       % Phase Margin and DC Open-Loop Gain
sysTransient = stepinfo(system);
trise = sysTransient.RiseTime;   % Rise Time

if isnan(Pfb)
    Pfb = 0;
end
if isnan(Pm)
    Pm = 0;
end
if isnan(Gol)
    Gol = 0;
end
if isnan(trise)
    trise = 0;
end

m = [iter Pfb Pm Gol trise];
dlmwrite('data.csv', m, 'delimiter', ',', '-append');

end