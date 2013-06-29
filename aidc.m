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
iterLimit  = 200;
droneCount = 50;

% Some converter characteristics
gm   = -0.1;
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
fprintf(fid, 'iter,Pfb,Pm,Gol,tr\n');
fclose(fid);

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
    
    fprintf('Age of Queen = %d\n', nestQueen.age)
    
    % Increment counter and waitbar
    waitbar(i/iterLimit, wait, sprintf('Simulating Generation %d of %d', i, iterLimit))
   
    % Save values for future plotting
    storeVariables(i, nestQueen);
   
    % Save queen snapshot every 10 iterations
    if mod(i,10) == 0 || i == 1
        K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
        sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
        [gain, phase] = bode(sys*boostTF());  
        magdbsq = squeeze(20*log10(gain(1,1,:)));
        phasesq = squeeze(phase(1,1,:));
        [Gol, Pm] = findPM(magdbsq, phasesq); 
        figure
        bode(sys*boostTF());
        h = gcf;
        set(h, 'Visible', 'off');
        title(sprintf('Generation %d, Fitness %.3g, \\phi_M = %.4g', i, fitness(nestQueen), Pm));
        filename = sprintf('images/generation%d.png',i);
        saveas(h, filename);
    end
end
delete(wait)
fprintf('Best Transfer Function\n')
fprintf('**********************\n')
K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
disp(K*tf(nestQueen.Gzc, nestQueen.Gpc))
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitness(nestQueen))


