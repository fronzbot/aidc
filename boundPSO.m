function [particle] = boundPSO(particle)
% Bounds the particle dimensions in case velocity increases and causes an
% invalid region to be entered
    particle.poleCount = round(particle.poleCount);
    particle.zeroCount = round(particle.zeroCount);
    particle.poleCount = abs(particle.poleCount);
    particle.zeroCount = abs(particle.zeroCount);
    if particle.poleCount < 2
        particle.poleCount = 2;
    end
    if particle.poleCount > 4
        particle.poleCount = 4;
    end
    if particle.zeroCount < 2
        particle.zeroCount = 2;
    end
    if particle.zeroCount > 3
        particle.zeroCount = 3;
    end
    if particle.Ro < 100
        particle.Ro = 100;
    end
    if particle.Ro > 1e9
        particle.Ro = 1e9;
    end
    if particle.RT < 10e3
        particle.RT = 10e3;
    end
    if particle.RT > 1e9
        particle.RT = 1e9;
    end

end