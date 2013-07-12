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
    controller = gm*pBest.Ro*pBest.RB/(pBest.RB+pBest.RT)*tf(pBest.zeroCoeffs, pBest.poleCoeffs);
    %controller = gm*pBest.Ro*pBest.RB/(pBest.RB+pBest.RT)*tf([pBest.Rz*pBest.Cz 1], [pBest.Ro*pBest.Cz 1]);
    system = boost*controller;
    
    % Get freqeuency info
    [pm, gainMarg, gain, bw] = getFreqInfo(system);
    
    % Normalize values
    pm       = pm/180;
    gain     = gain/100;
    gainMarg = gainMarg/60; 
    bw       = log(bw)/5;
    
    % Create parabolas
    f_pm = -(pm-60/180)^2+1;
    f_g  = -(gain-60/100)^2+1;
    f_gm = -(gainMarg-20/60)^2+1;
    f_bw = -0.8*(bw-3.5/5)^2+1;
    
    fitVal = (3*f_pm + f_g + f_gm + 1.8*f_bw);
end