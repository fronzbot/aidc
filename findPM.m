% Brute force way to find open-loop gain and phase margin
% written because the margin function is a piece of shit

function [ dcgain, phaseMargin ] = findPM(gain, phase)
    phaseStart = phase(1);
    dcgain = 20*log10(gain(1));
    if dcgain <= 0
        phaseMargin = -180;
        return
    end
    for i = 2:length(gain)
        if gain(i) < 0 && gain(i) > -10
            if phase(i) > phaseStart
                phaseMargin = -180;
            elseif phaseStart < 190 && phaseStart > 170
                phaseMargin = phase(i);
            elseif phaseStart < 100 && phaseStart > 80
                phaseMargin = 90 + phase(i);
            elseif phaseStart < 10 && phaseStart > -10
                phaseMargin = 180 + phase(i);
            elseif phaseStart < -100 && phaseStart > -80
                phaseMargin = 270 + phase(i);
            elseif phaseStart < 370 && phaseStart > 350
                phaseMargin = 180 - phase(i);
            else
                phaseMargin = -90;
            end
        else
            phaseMargin = -90;
        end
    end
end