function [particle] = boundPSO(particle)
% Bounds the particle dimensions in case velocity increases and causes an
% invalid region to be entered
    if particle.poleCount < 1
        particle.poleCount = 1;
    end
    if particle.poleCount > 4
        particle.poleCount = 4;
    end
    if particle.zeroCount < 1
        particle.zeroCount = 1;
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
%     if particle.Rz > particle.Ro
%         particle.Rx = particle.Ro/2;
%     end
    if particle.RT < 10e3
        particle.RT = 10e3;
    end
    if particle.RT > 1e9
        particle.RT = 1e9;
    end

end