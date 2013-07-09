function [phaseMarg, gainMarg, dcGain, bandwidth] = getFreqInfo(system)
    freq = logspace(0,9,100);
    [mag, phase] = bode(system,freq);
    magdb = squeeze(20*log10(mag(1,1,:)));
    phase = squeeze(phase(1,1,:));
    dcGain = magdb(1);
    phaseMarg = -180;
    gainMarg  = -100;
    bandwidth = 0;
    % If phase starts at 360 or 270 (for integrator)
    if (phase(1) <= 380 && phase(1) >= 340) || (phase(1) <= 290 && phase(1) >= 250)
        phaseMod  = 180;
        phaseHigh = 185;
        phaseLow  = 175;
    % If phase starts at 0 or -90 (for integrator)    
    elseif (phase(1) <= 20 && phase(1) >= -20) || (phase(1) <= -70 && phase(1) >= -110)
        phaseMod  = -180;
        phaseHigh = -175;
        phaseLow  = -185;
    else
        phaseMarg = -180;
        gainMarg  = -100;
        return
    end
    
    for i = 1:length(magdb)
        % Get Phase Margin and Bandwidth
        if magdb(i) <= 5 && magdb(i) >= -5
            phaseMarg = phase(i)-phaseMod;
            bandwidth = freq(i);
        end
        % Get Gain Margin
        if phase(i) <= phaseHigh && phase(i) >= phaseLow
            gainMarg = -magdb(i);
        end
        
    end
    if phaseMarg < 0 && gainMarg > 0
        gainMarg = -gainMarg;
    end
    
    if phaseMarg > 100
        phaseMarg = -180;
    end
    if bandwidth > 100e3
        bandwidth = 1;
    end
    
end