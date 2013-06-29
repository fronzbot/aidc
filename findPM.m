% Brute force way to find open-loop gain and phase margin
% written because the margin function is a piece of shit

function [ dcgain, phaseMargin ] = findPM(gain, phase)
    phaseStart = phase(1);
    dcgain = 20*log10(gain(1));
    for i = 2:length(gain)
        if gain(i) < 0
            if phaseStart < 185 && phaseStart > 175
                phaseMargin = phase(i);
            elseif phaseStart < 95 && phaseStart > 85
                phaseMargin = 90 + phase(i);
            elseif phaseStart < 5 && phaseStart > -5
                phaseMargin = 180 + phase(i);
            elseif phaseStart < -95 && phaseStart > -85
                phaseMargin = 270 + phase(i);
            elseif phaseStart < 365 && phaseStart > 355
                phaseMargin = 180 - phase(i);
            end
        else
            phaseMargin = -90;
        end
    end
end