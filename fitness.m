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
W = [0.05, 0.5, 0.2, 0.25];


Pfb = bee.Vo^2/(bee.Grb+bee.Grt);    % Power
[gain, phase] = bode(system);  
magdbsq = squeeze(20*log10(gain(1,1,:)));
phasesq = squeeze(phase(1,1,:));
[Gol, Pm] = findPM(magdbsq, phasesq);       % Phase Margin and DC Open-Loop Gain
sysTransient = stepinfo(system);
trise = sysTransient.RiseTime;       % Rise Time

% Make sure all variables are valid
if isnan(Pfb) || abs(Pfb) == Inf
    Pfb = 0;
end
if isnan(Pm) || abs(Pm) == Inf
    Pm = 0;
end
if isnan(Gol) || abs(Gol) == Inf
    Gol = 0;
end
if isnan(trise) || abs(trise) == Inf
    trise = 0;
end

% Generate fitness criteria for each variable
f_Pfb = -2e6*Pfb + 2000;
f_Pm  = 25*Pm - 250;
f_Gol = 29*Gol - 285;
f_tr  = -40e3*trise + 2000;

% Create penalties if outside range
if outsideRange(Pfb, 10e-9, 1e-3) == 1
    if Pfb > 1e-3
        f_Pfb = -2000*Pfb - 8;
    else
        f_Pfb = 2e11*Pfb - 2000;
    end
end

if outsideRange(Pm, 10, 90) == 1
    if Pm > 90
        f_Pm = -33*Pm + 4000;
    else
        f_Pm = 18*Pm - 200;
    end
end

if outsideRange(Gol, 10, 80) == 1
    if Gol > 80
        f_Gol = -35*Gol + 2900;
    else
        f_Gol = -100*Gol - 10;
    end
end

if outsideRange(trise, 10e-9, 10e-3) == 1
    if trise > 10e-3
       f_tr = -2000*trise + 10; 
    else
       f_tr = 2e11*trise - 2000;
    end
end

fitValue = W(1)*f_Pfb + W(2)*f_Pm + W(3)*f_Gol + W(4)*f_tr;
end


