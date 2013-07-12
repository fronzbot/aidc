% Kevin Fronczak
% aidc
% PSO.m
% 2013.07.08
close all force;
clear

swarmSize = 20;
iterMax   = 10;
%PSO is the PSO algorithm that iterates through each variable (dimension)
%and finds returns the optimal solution.
vars = {'poleCount', 'zeroCount', 'poleCoeffs', 'zeroCoeffs', 'Ro', 'RT'};

bounds.poleCount  = [1, 4];
bounds.zeroCount  = [1, 3];
bounds.poleCoeffs = [0, 1];
bounds.zeroCoeffs = [0, 1];
bounds.Ro         = [1e3, 100e3];
bounds.RT         = [100e3, 10e6];

c(1).poleCount  = 2; c(2).poleCount  = 2;
c(1).zeroCount  = 2; c(2).zeroCount  = 2;
c(1).poleCoeffs = 2; c(2).poleCoeffs = 2;
c(1).zeroCoeffs = 2; c(2).zeroCoeffs = 2;
c(1).Ro         = 2; c(2).Ro         = 2;
c(1).RT         = 2; c(2).RT         = 2;

for i = 1:length(vars)
    gBest.(vars{i}) = 'empty';
end


wait = waitbar(0, sprintf('Initializing Particle %d of %d', 0, swarmSize), ...
               'Name', 'AIDC - PSO Simulation');%, ...
               %'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)


for i = 1:swarmSize

    % Increment counter and waitbar
    waitbar(i/swarmSize, wait, sprintf('Initializing Particle %d of %d', i, swarmSize))
    
    % Initialize particle position
    for j = 1:length(vars)
        bndLow  = bounds.(vars{j})(1);
        bndHigh = bounds.(vars{j})(2);

        if strcmp('zeroCount', vars{j}) && p(i).poleCount < 4
            % Bound zero count to be lower than or equal to poleCount
            bndHigh = p(i).poleCount;
        end
        
        if strcmp('poleCoeffs', vars{j})
            % Make the coeffs an array
            for k = 1:p(i).poleCount
                p(i).poleCoeffs(k) = unifrnd(bndLow, bndHigh);
            end
            p(i).poleCoeffs(end) = 1;
        elseif strcmp('zeroCoeffs', vars{j})
            % Makes the coeffs an array
            for k = 1:p(i).zeroCount
                p(i).zeroCoeffs(k) = unifrnd(bndLow, bndHigh);
            end
            p(i).zeroCoeffs(end) = 1;
        else     
            p(i).(vars{j}) = unifrnd(bndLow, bndHigh);
        end
        
        % Update particle best position
        p(i).localBest.(vars{j}) = p(i).(vars{j});
        
        
        % Initialize particle velocity
        p(i).vel.(vars{j}) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
        p(i).vel.(vars{j}) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
        
        % Check if global best has not been set
        if strcmp('empty', gBest.(vars{j}))
            gBest.(vars{j}) = p(i).localBest.(vars{j});
        end
    end
    
    % Bound values if need be
    p(i) = boundPSO(p(i));
    
    % Update global best position
    if psoFit(p(i).localBest) < psoFit(gBest)
        gBest = p(i).localBest;
        gBest.RB = 1/3.583*gBest.RT;
    end
    fitness(1) = psoFit(gBest);
end
close(wait)


wait = waitbar(0, sprintf('PSO Iteration %d of %d', 0, iterMax), ...
               'Name', 'AIDC - PSO Simulation', ...
               'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)

% Run actual PSO
for k = 1:iterMax
    % Check for Cancel Button Press
    if getappdata(wait,'canceling')
        fprintf('\nExiting Program at Iteration %d \n\n',k);
        break
    end
    
    % Increment counter and waitbar
    waitbar(k/iterMax, wait, sprintf('PSO Iteration %d of %d', k, iterMax))
    
    for i = 1:swarmSize
        for j = 1:length(vars)
            % Update velocity and position
            if strcmp('poleCoeffs', vars{j})
                for n = 1:length(p(i).poleCoeffs)
                    p(i).vel.(vars{j}) = p(i).vel.(vars{j}) + c(1).(vars{j})*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                         c(2).(vars{j})*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n));
                    p(i).vel.(vars{j}) = p(i).(vars{j})(n) + p(i).vel.(vars{j});
                end
            elseif strcmp('zeroCoeffs', vars{j})
                for n = 1:length(p(i).zeroCoeffs)
                    p(i).vel.(vars{j}) = p(i).vel.(vars{j}) + c(1).(vars{j})*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                         c(2).(vars{j})*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n));
                    p(i).vel.(vars{j}) = p(i).(vars{j})(n) + p(i).vel.(vars{j});
                end
            else
                p(i).vel.(vars{j}) = p(i).vel.(vars{j}) + c(1).(vars{j})*rand()*(p(i).localBest.(vars{j}) - p(i).(vars{j})) + ...
                                     c(2).(vars{j})*rand()*(gBest.(vars{j}) - p(i).(vars{j}));
                p(i).vel.(vars{j}) = p(i).(vars{j}) + p(i).vel.(vars{j});
            end
        end
    % Update best local positions
        if psoFit(p(i)) < psoFit(p(i).localBest)
            p(i).localBest = p(i);
        end
        if psoFit(p(i).localBest) < psoFit(gBest)
            gBest = p(i).localBest;
            gBest.RB = 1/3.583*gBest.RT;
        end
        
    end
    fitness(k+1) = psoFit(gBest);
    
    if mod(k,5) == 0 || k == 1
        K = 0.1*gBest.Ro*gBest.RB/(gBest.RB+gBest.RT);
        sys = K*tf(gBest.zeroCoeffs, gBest.poleCoeffs);
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF()*sys);
        figure(1)
        step(feedback(sys*boostTF(),1));
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', i, fitness(nestQueen), gain, pm, Gmarg, bw));
        h = gcf;
        set(findall(h,'type','text'),'fontName','Book Antiqua','fontSize',8, 'fontWeight', 'bold')
        set(h, 'Visible', 'off');
        filename = sprintf('images/generation%d.png',k);
        saveas(h, filename);
    end
end
delete(wait)

figure
plot(fitness)
title('Fitness of PSO')
xlabel('Iteration')
ylabel('Fitness of Global Best')

