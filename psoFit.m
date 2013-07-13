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
    
    % Get freqeuency info
    [pm, gainMarg, gain, bw] = getFreqInfo(system);
    
    % Normalize values
    pm       = pm/70;
    gain     = gain/60;
    gainMarg = gainMarg/40; 
    bw       = bw/2e3;
    
    % Create Penalties
    penalty = 0;
    if outsideRange(gain, 0.3, 1.2)
        penalty = penalty + 2*max(5, abs(gain));
    end
    if outsideRange(pm, 0.3, 1.2)
        penalty = penalty + 3*max(5, abs(pm));
    end
    if outsideRange(gainMarg, 0.3, 1.2)
        penalty = penalty + 2*max(5, abs(gainMarg));
    end
    if outsideRange(bw, 0.3, 1.2)
        penalty = penalty + 2*max(5, abs(bw));
    end

    fitVal = (3*pm + 2*gain + 0.6*gainMarg + 1.8*bw)-penalty;
 
end