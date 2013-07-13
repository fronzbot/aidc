% Kevin Fronczak
% aidc
% aidc.m
% 2013.06.28

close all force;
clear
warning('off', 'Control:analysis:MarginUnstable')
% This program begins the GA to optimize the controller design for a
% switched DC-DC converter.

% Set maximum number of allowed iterations and number of children
iterLimit  = 50;
droneCount = 30;

tic

% Some converter characteristics
gm   = 0.1;
Vout = 5.5;
Vref = 1.2;

% fprintf('F(Pfb)\tF(Pm)\tF(G)\tF(tr)\n--------------------\n')

wait = waitbar(0, sprintf('Simulating Generation %d of %d', 0, iterLimit), ...
               'Name', 'AIDC - Genetic Algorithm Simulation', ...
               'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)

drones = makeDrones(Vout, Vref, gm, droneCount);

% Get queen from initial drones
nestQueen = drones(1);
for i = 2:length(drones)
    nestQueen = queenCompete(nestQueen, drones(i));
end

nestQueen.age = 0;

% Write headers to csv file
fid = fopen('data.csv','wt');
fprintf(fid, 'generation,fitness,tr,ts,os,pm,gain\n');
fclose(fid);

fitnessValues(1) = fitness(nestQueen);

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
    virginQueen = GA(nestQueen, drones, Vout, Vref);
    nestQueen   = queenCompete(nestQueen, virginQueen);
    drones      = makeDrones(Vout, Vref, gm, droneCount);
    
    fitnessValues(i+1) = fitness(nestQueen);
    
    % Increment counter and waitbar
    waitbar(i/iterLimit, wait, sprintf('Simulating Generation %d of %d', i, iterLimit))
   
    % Save values for future plotting
    storeVariables(i, nestQueen);
   
    % Save queen snapshot every 5 iterations
    if mod(i,5) == 0 || i == 1
        K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
        sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF()*sys);
        [y,t]=step(feedback(sys*boostTF(),1));
        figure
        plot(t,y);
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', i, fitness(nestQueen), gain, pm, Gmarg, bw));
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



fprintf('Best Transfer Function\n')
fprintf('**********************\n')
K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
K*tf(nestQueen.Gzc, nestQueen.Gpc)
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitness(nestQueen))

figure
plot(1:length(fitnessValues),fitnessValues)
title('Fitness Per Generation')
xlabel('Generation')
ylabel('Fitness Value')

toc

