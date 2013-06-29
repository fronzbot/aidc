% Kevin Fronczak
% aidc
% aidc.m
% 2013.06.28

close all;
clear
warning('off', 'Control:analysis:MarginUnstable')
% This program begins the GA to optimize the controller design for a
% switched DC-DC converter.

% Set maximum number of allowed iterations and number of children
iterLimit  = 10;
droneCount = 5;

% Some converter characteristics
gm   = -0.1;
Vout = 5.5;
Vref = 1.2;

i = 0;
wait = waitbar(0, sprintf('Simulating Generation %d of %d', 0, iterLimit));

drones = makeDrones(Vout, Vref, gm, droneCount);

% Get queen from initial drones
nestQueen = drones(1);
for i = 2:length(drones)
    nestQueen = queenCompete(nestQueen, drones(i));
end

% Write headers to csv file
fid = fopen('data.csv','wt');
fprintf(fid, 'iter,Pfb,Pm,Gol,tr\n');
fclose(fid);

for i = 1:iterLimit
   virginQueen = GA(nestQueen, drones, Vout, Vref);
   nestQueen   = queenCompete(nestQueen, virginQueen);
   drones      = makeDrones(Vout, Vref, gm, droneCount);
   
   % Increment counter and waitbar
   waitbar(i/iterLimit, wait, sprintf('Simulating Generation %d of %d', i, iterLimit))
   
   % Save values for future plotting
   storeVariables(i, nestQueen);
   
   % Save queen snapshot every 10 iterations
   if mod(i,10) == 0 || i == 1
       K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
       sys = K*tf(nestQueen.Gzc, nestQueen.Gpc);
       figure
       bode(sys*boostTF());
       h = gcf;
       set(h, 'Visible', 'off');
       title(sprintf('Generation %d, Fitness %.3g', i, fitness(nestQueen)));
       filename = sprintf('images/generation%d.png',i);
       saveas(h, filename);
   end
end
close(wait)
fprintf('Best Transfer Function\n')
fprintf('**********************\n')
K = nestQueen.gm * nestQueen.Gro * nestQueen.Grb/(nestQueen.Grt+nestQueen.Grb);
disp(K*tf(nestQueen.Gzc, nestQueen.Gpc))
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitness(nestQueen))


