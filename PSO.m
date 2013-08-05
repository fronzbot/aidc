% Kevin Fronczak
% aidc
% PSO.m
% 2013.07.08

function [fitnessValues] = PSO(opts)
%PSO is the PSO algorithm that iterates through each variable (dimension)
%and finds returns the optimal solution.


PRINT = opts.Print;
PLOT  = opts.Plot;

tic
swarmSize = opts.Size;
iterMax   = opts.Iter;

vars = {'poleCount', 'zeroCount', 'poleCoeffs', 'zeroCoeffs', 'Ro', 'RT'};

bounds.poleCount  = [2, 4];
bounds.zeroCount  = [2, 3];
bounds.poleCoeffs = [1/(2*pi*1e7), 1/(2*pi)];    
bounds.zeroCoeffs = [1/(2*pi*1e7), 1/(2*pi)];     
bounds.Ro         = [1e3, 100e6];
bounds.RT         = [100e3, 10e6];


if strcmpi(opts.PSOType, 'Constrict')
    constrict = true;
    cdiw = false;
    criw = false;
    % Velocity Coefficients
    c1 = 1; c2 = 3.1;

    % Constriction Factor
    phi = c1+c2;
    CHI = -2/(2-phi-sqrt(phi^2-4*phi));
elseif strcmpi(opts.PSOType, 'CDIW')
    constrict = false;
    cdiw = true;
    criw = false;
    % Set initial and final weights
    w1 = 0.9; w2 = 0.4;
    
    % Set velocity coefficients
    c1 = 2; c2 = 2;
elseif strcmpi(opts.PSOType, 'CRIW')
    constrict = false;
    cdiw = false;
    criw = true;
   
    % Set velocity coefficients
    c1 = 2; c2 = 2;
end

for i = 1:length(vars)
    gBest.(vars{i}) = 'empty';
end

wait = waitbar(0, sprintf('Initializing Particle %d of %d', 0, swarmSize), ...
               'Name', 'AIDC - PSO Simulation');%, ...
               %'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)

%%%%%%%%%%%%%%%%%%%%
%%% FIGURE STUFF %%%
%%%%%%%%%%%%%%%%%%%%
t = 0:0.1:1;
y = 1;
figure
h = plot(t,y,'k','LineWidth',3);
set(h, 'YDataSource', 'y');
set(h, 'XDataSource', 't');
title('Starting Point')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SWARM INITIALIZATION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:swarmSize
    % Initialize array sizes to maximum allowed values
    p(i).poleCoeffs           = zeros(1,4);
    p(i).zeroCoeffs           = zeros(1,3);
    p(i).vel.poleCoeffs       = zeros(1,4);
    p(i).vel.zeroCoeffs       = zeros(1,3);
    p(i).localBest.poleCoeffs = zeros(1,4);
    p(i).localBest.zeroCoeffs = zeros(1,3);
    
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
                randFreq = (randi(9)+rand())*10^(randi(6));
                p(i).poleCoeffs(k) = 1./(2*pi*randFreq);
            end
            %p(i).poleCoeffs(end) = 1;
        elseif strcmp('zeroCoeffs', vars{j})
            % Makes the coeffs an array
            for k = 1:p(i).zeroCount
                randFreq = (randi(9)+rand())*10^(randi(6));
                p(i).zeroCoeffs(k) = 1./(2*pi*randFreq);
            end
            %p(i).zeroCoeffs(end) = 1;
        else     
            p(i).(vars{j}) = unifrnd(bndLow, bndHigh);
        end
        
        if strcmp('poleCount', vars{j})
            p(i).poleCount = round(p(i).poleCount);
        elseif strcmp('zeroCount', vars{j})
            p(i).zeroCount = round(p(i).zeroCount);
        end
        
        % Update particle best position
        p(i).localBest.(vars{j}) = p(i).(vars{j});
        
        % Initialize particle velocity
        if strcmp('poleCoeffs', vars{j})
            for n = 1:p(i).poleCount
                p(i).vel.(vars{j})(n) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
                p(i).vel.(vars{j})(n) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
            end
        elseif strcmp('zeroCoeffs', vars{j})
            for n = 1:p(i).zeroCount
                p(i).vel.(vars{j})(n) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
                p(i).vel.(vars{j})(n) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
            end
        else
            p(i).vel.(vars{j}) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
            p(i).vel.(vars{j}) = unifrnd(-abs(bndHigh-bndLow), abs(bndHigh-bndLow));
        end

        % Check if global best has not been set
        if strcmp('empty', gBest.(vars{j}))
            gBest.(vars{j}) = p(i).localBest.(vars{j});
        end
        
    end
    gBest.RB = 1/3.583*gBest.RT;
    
    % Update global best position
    if psoFit(p(i).localBest, opts) > psoFit(gBest, opts)
        gBest = p(i).localBest;
        gBest.RB = 1/3.583*gBest.RT;
    end
    fitnessValues(1) = psoFit(gBest, opts);
end
close(wait)


wait = waitbar(0, sprintf('PSO Iteration %d of %d', 0, iterMax), ...
               'Name', 'AIDC - PSO Simulation', ...
               'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)

denom = iterMax*swarmSize;
progress = 0;


%%%%%%%%%%%%%%%
%%% RUN PSO %%%
%%%%%%%%%%%%%%%
for k = 1:iterMax
    
    % Check for Cancel Button Press
    if getappdata(wait,'canceling')
        fprintf('\nExiting Program at Iteration %d \n\n',k);
        break
    end
    
    for i = 1:swarmSize
        % Increment counter and waitbar
        progress = progress + 1;
        waitbar(progress/denom, wait, sprintf('PSO Iteration %d of %d', k, iterMax))
        
        
        for j = 1:length(vars)
            % Constrain pole/zero Count to be integers
            p(i) = boundPSO(p(i));
           
            if p(i).zeroCount > p(i).poleCount
                p(i).zeroCount = p(i).poleCount;
            end
            % Update velocity and position
            if strcmp('poleCoeffs', vars{j})
                for n = 1:p(i).poleCount
                    if constrict
                        % Use Constriction for Velocity
                        p(i).vel.(vars{j})(n) = CHI*(p(i).vel.(vars{j})(n) + c1*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                                c2*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n)));
                        p(i).(vars{j})(n) = abs(p(i).(vars{j})(n) + p(i).vel.(vars{j})(n));
                    else
                        % Use Chaotic Intertial Weight for Velocity
                        z = rand();
                        z = 4*z*(1-z);
                        if cdiw
                            w = (w1-w2)*(iterMax-k)/iterMax + z*w2;
                        elseif criw
                            w = 0.5*rand()+0.5*z;
                        end
                     
                        p(i).vel.(vars{j})(n) = w*p(i).vel.(vars{j})(n) + c1*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                                c2*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n));
                        p(i).(vars{j})(n) = abs(p(i).(vars{j})(n) + p(i).vel.(vars{j})(n));

                    end
                end
                
            elseif strcmp('zeroCoeffs', vars{j})
                for n = 1:p(i).zeroCount
                    if constrict
                        % Use Constriction for Velocity
                        p(i).vel.(vars{j})(n) = CHI*(p(i).vel.(vars{j})(n) + c1*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                                c2*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n)));
                        p(i).(vars{j})(n) = abs(p(i).(vars{j})(n) + p(i).vel.(vars{j})(n));
                    else
                        % Use Chaotic Inertial Weight for Velocity
                        z = rand();
                        z = 4*z*(1-z);
                        if cdiw
                            w = (w1-w2)*(iterMax-k)/iterMax + z*w2;
                        elseif criw
                            w = 0.5*rand()+0.5*z;
                        end
                        
                        p(i).vel.(vars{j})(n) = w*p(i).vel.(vars{j})(n) + c1*rand()*(p(i).localBest.(vars{j})(n) - p(i).(vars{j})(n)) + ...
                                                c2*rand()*(gBest.(vars{j})(n) - p(i).(vars{j})(n));
                        p(i).(vars{j})(n) = abs(p(i).(vars{j})(n) + p(i).vel.(vars{j})(n));
                    end
                end
                
            else
                if constrict
                    % Use Constriction for Velocity
                    p(i).vel.(vars{j}) = CHI*(p(i).vel.(vars{j}) + c1*rand()*(p(i).localBest.(vars{j}) - p(i).(vars{j})) + ...
                                         c2*rand()*(gBest.(vars{j}) - p(i).(vars{j})));
                    p(i).(vars{j}) = p(i).(vars{j}) + p(i).vel.(vars{j});
                else
                    % Use Chaotic Interval Weight for Velocity
                    z = rand();
                    z = 4*z*(1-z);
                    if cdiw
                        w = (w1-w2)*(iterMax-k)/iterMax + z*w2;
                    elseif criw
                        w = 0.5*rand()+0.5*z;
                    end
                    p(i).vel.(vars{j}) = w*p(i).vel.(vars{j}) + c1*rand()*(p(i).localBest.(vars{j}) - p(i).(vars{j})) + ...
                                         c2*rand()*(gBest.(vars{j}) - p(i).(vars{j}));
                    p(i).(vars{j}) = p(i).(vars{j}) + p(i).vel.(vars{j});
                end
                    
            end
        end
        
        % Constrain pole/zero Count to be integers
        % within the valid operating range
        p(i) = boundPSO(p(i));
        
        % Update best local positions
        if psoFit(p(i), opts) > psoFit(p(i).localBest, opts)
            p(i).localBest = p(i);
        end
        if psoFit(p(i).localBest, opts) > psoFit(gBest, opts)
            gBest = p(i).localBest;
            gBest.RB = 1/3.583*gBest.RT;
        end

    end
    fitnessValues(k+1) = psoFit(gBest, opts);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FIGURE PRINTING/PLOTTING %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if PLOT
        K = 0.1*gBest.Ro*gBest.RB/(gBest.RB+gBest.RT);
        sys = K*tf(gBest.zeroCoeffs(1:gBest.zeroCount), gBest.poleCoeffs(1:gBest.poleCount));
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF(opts)*sys);
        [y,t] = step(feedback(sys*boostTF(opts),1));
        refreshdata(h,'caller')
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', k, psoFit(gBest, opts), gain, pm, Gmarg, bw));
    end
    
    if (mod(k,opts.PrintNum) == 0 || k == 1) && PRINT
        K = 0.1*gBest.Ro*gBest.RB/(gBest.RB+gBest.RT);
        sys = K*tf(gBest.zeroCoeffs(1:gBest.zeroCount), gBest.poleCoeffs(1:gBest.poleCount));
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF(opts)*sys);
        [y,t] = step(feedback(sys*boostTF(opts),1));
        figure
        plot(t,y);
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', k, psoFit(gBest, opts), gain, pm, Gmarg, bw));
        xlabel('Time [s]')
        ylabel('Amplitude')
        h = gcf;
        hl = 0;
        fixFig(h,hl,'Best',false)
        set(h, 'Visible', 'off');
        filename = sprintf('images/iteration%d.png',k);
        r = 600; % pixels per inch
        print(gcf,'-dpng',sprintf('-r%d',r), filename);
    end

end
delete(wait)

%%%%%%%%%%%%%%%%%%%%%
%%% PRINT RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%
fprintf('Best Transfer Function\n')
fprintf('**********************\n')
K = 0.1*gBest.Ro*gBest.RB/(gBest.RB+gBest.RT);
sys= K*tf(gBest.zeroCoeffs(1:gBest.zeroCount), gBest.poleCoeffs(1:gBest.poleCount))
fprintf('\tRT=%.3g\tRB=%.3g\n',gBest.RT, gBest.RB)
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', psoFit(gBest, opts))

figure
plot(1:length(fitnessValues),fitnessValues)
title('Fitness of PSO')
xlabel('Iteration')
ylabel('Fitness of Global Best')
toc

end