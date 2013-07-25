% Kevin Fronczak
% aidc
% GA.m
% 2013.06.28

function [fitnessValues] = GA(opts)
% This program begins the GA to optimize the controller design for a
% switched DC-DC converter.

PRINT = opts.Print;
PLOT  = opts.Plot;

% Set maximum number of allowed iterations and number of children
iterLimit  = opts.Iter;
droneCount = opts.Size;

tic

% Some converter characteristics
gm   = 0.1;
Vout = 5.5;
Vref = 1.2;

wait = waitbar(0, sprintf('Simulating Generation %d of %d', 0, iterLimit), ...
               'Name', 'AIDC - Genetic Algorithm Simulation', ...
               'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)

drones = makeDrones(Vout, Vref, gm, droneCount);


%%%%%%%%%%%%%%%%%%%%
%%% FIGURE STUFF %%%
%%%%%%%%%%%%%%%%%%%%
tval = 0:0.1:1;
yval = 1;
figure
h = plot(tval,yval,'k','LineWidth',3);
set(h, 'YDataSource', 'yval');
set(h, 'XDataSource', 'tval');
title('Starting Point')


% Get queen from initial drones
nestQueen = drones(1);
for i = 2:length(drones)
    nestQueen = queenCompete(nestQueen, drones(i), opts);
end

nestQueen.age = 0;

% Write headers to csv file
fid = fopen('data.csv','wt');
fprintf(fid, 'generation,fitness,tr,ts,os,pm,gain\n');
fclose(fid);

fitnessValues(1) = fitness(nestQueen, opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%          GA         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:iterLimit
    nestQueen.age = nestQueen.age + 1;
    % Check for Cancel Button Press
    if getappdata(wait,'canceling')
        fprintf('\nExiting Program at Generation %d \n\n',i);
        break
    end
    virginQueen = QBGA(nestQueen, drones, Vout, Vref, opts);
    nestQueen   = queenCompete(nestQueen, virginQueen, opts);
    drones      = makeDrones(Vout, Vref, gm, droneCount);
    
    fitnessValues(i+1) = fitness(nestQueen, opts);
    
    % Increment counter and waitbar
    waitbar(i/iterLimit, wait, sprintf('Simulating Generation %d of %d', i, iterLimit))
   
    % Save values for future plotting (for debugging)
    % storeVariables(i, nestQueen, opts);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FIGURE PRINTING/PLOTTING %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if PLOT
        K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
        sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
        system = sys*boostTF(opts);
        [pm, Gmarg, gain, bw] = getFreqInfo(system);
        [yval,tval]=step(feedback(system, 1));
        refreshdata(h, 'caller')
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', i, fitness(nestQueen, opts), gain, pm, Gmarg, bw));
    end
    
    
    % Save queen snapshot every give iteration
    if (mod(i,opts.PrintNum) == 0 || i == 1) && PRINT
        K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
        sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF(opts)*sys);
        [y,t]=step(feedback(sys*boostTF(opts),1));
        figure
        plot(t,y);
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', i, fitness(nestQueen, opts), gain, pm, Gmarg, bw));
        xlabel('Time [s]')
        ylabel('Amplitude')
        h = gcf;
        hl = 0;
        fixFig(h,hl,'Best',false)
        set(h, 'Visible', 'off');
        filename = sprintf('images/generation%d.png',i);
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
K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
K*tf(nestQueen.Gzc, nestQueen.Gpc)
fprintf('\tRT=%.3g\tRB=%.3g\n',nestQueen.Grt, nestQueen.Grb)
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitness(nestQueen, opts))

figure
plot(1:length(fitnessValues),fitnessValues)
title('Fitness Per Generation')
xlabel('Generation')
ylabel('Fitness Value')

toc

end