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
iterLimit  = 20;
droneCount = 20;

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
    
    % Increment counter and waitbar
    waitbar(i/iterLimit, wait, sprintf('Simulating Generation %d of %d', i, iterLimit))
   
    % Save values for future plotting
    storeVariables(i, nestQueen);
   
    % Save queen snapshot every 5 iterations
    if mod(i,5) == 0 || i == 1
        K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
        sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
        [pm, Gmarg, gain, bw] = getFreqInfo(boostTF()*sys);
        figure(1)
        step(feedback(sys*boostTF(),1));
        title(sprintf('Gen %d, Fit %.3g, Gain = %.3g dB,\n \\phi_M = %.3g, Gm = %.3g, BW = %.3g', i, fitness(nestQueen), gain, pm, Gmarg, bw));
        h = gcf;
        set(findall(h,'type','text'),'fontName','Book Antiqua','fontSize',8, 'fontWeight', 'bold')
        set(h, 'Visible', 'off');
        filename = sprintf('images/generation%d.png',i);
        saveas(h, filename);
    end
end
delete(wait)


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         PSO         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Optimize Component Values
wait = waitbar(0, sprintf('Optimizing Components %d%', 0), ...
               'Name', 'AIDC - Genetic Algorithm Simulation', ...
               'CreateCancelBtn', 'setappdata(gcbf, ''canceling'', 1)');
setappdata(wait,'canceling',0)
iter = 0;
total = nestQueen.Gzn + nestQueen.Gpn;
for i = 1:nestQueen.Gzn
    [nestQueen.ZeroRs(i), nestQueen.ZeroCs(i)] = PSO(nestQueen.Gzc(i));
    % Increment counter and waitbar
    iter = iter+1;
    waitbar(iter/total, wait, sprintf('Optimizing Components %d%', 0))
end

for i = 1:nestQueen.Gpn
    [nestQueen.PoleRs(i), nestQueen.PoleCs(i)] = PSO(nestQueen.Gpc(i));
    % Increment counter and waitbar
    iter = iter+1;
    waitbar(iter/total, wait, sprintf('Optimizing Components %d%', 0))
end
delete(wait)

fprintf('Best Transfer Function\n')
fprintf('**********************\n')
K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
K*tf(nestQueen.Gzc, nestQueen.Gpc)
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitness(nestQueen))



