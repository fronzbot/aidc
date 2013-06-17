% Kevin Fronczak
% aidc
% aidc.m
% 2013.06.16
close all;
clear
warning('off', 'Control:analysis:MarginUnstable')
warning('off', 'Control:analysis:DCGainInfinite')
% This program begins the GA to optimize the controller design for a
% switched DC-DC converter.

% Set maximum number of allowed iterations and number of children
iterLimit = 100;
children  = 20;

% Some converter characteristics
gm   = -1;
Vout = 5.5;
Vref = 1.2;

i = 0;
wait = waitbar(0, 'Evolution at 0%');

[bestZeros, bestPoles, bestRo, bestRT, bestRB] = initialization(Vout, Vref, gm, children);
while i < iterLimit
   [allZeros, allPoles, allRo, allRT, allRB] = GA(bestZeros, ...
                                                  bestPoles, ...
                                                  bestRo, ...
                                                  bestRT, ...
                                                  bestRB, ...
                                                  gm, ...
                                                  children);
   
   allGain  = gm.*allRo.*allRB./(allRT+allRB);
   fitArray = fitness(allZeros, allPoles, allRT, allRB, allGain);

   % Find top two performing functions
   [fitvals, indices] = sort(fitArray(:), 'descend');
   parent1 = indices(1);
   parent2 = indices(2);

   bestZeros = [allZeros(parent1,:); allZeros(parent2,:)];
   bestPole  = [allPoles(parent1,:); allPoles(parent2,:)];
   bestRo    = [allRo(parent1);    allRo(parent2)];
   bestRT    = [allRT(parent1);    allRT(parent2)];
   bestRB    = [allRB(parent1);    allRB(parent2)];
    
   % Increment counter and waitbar
   i = i + 1;
   completion = int32(i/iterLimit*100);
   waitbar(i/iterLimit, wait, sprintf('Evolution at %d%%', completion))
end
close(wait)
fprintf('Best Transfer Function\n')
fprintf('**********************\n')
sys = gm*bestRo(1)*bestRB(1)/(bestRB(1)+bestRT(1))*tf(bestZeros(1,:), bestPoles(1,:))
fprintf('**********************\n')
fprintf('With Fitness: %.3g\n', fitvals(parent1))

% Check graphically with system
figure(1)
bode(sys)
title('Best Controller Transfer Function')

% Boost DCM ideal TF
R  = 1;
L  = 18e-6;
C  = 4.7e-6;
Vo = 5.5;
Vs = 2.75;
Fs = 350e3;

D = sqrt(2*Vo*L*Fs/R)*sqrt(Vo-Vs)/Vs;
t = L*Fs/R;
M = 1/2*(1+sqrt(1+2*D^2/t));
K = M*t;

Gdo = 2*Vo/(1+D);
wz1 = 2*K^2/(D^2*L/R*(D/2-D-K/D));
wo = 1/sqrt(L*C)*sqrt((4*K^2*D+4*K^2)/(D^4+4*D^2*K+4*K^2));
Q = 4*K^2*(D+1)/wo * 1/(4*R*C*D*K^2+L/R*(D^4+4*D^2*K+4*K^2)+L/R*D^3);

top = [1/wz1 1];
bot = [1/wo^2 1/(Q*wo) 1];
boost = Gdo*tf(top,bot);

figure(2)
sys2 = sys*boost/2.5;
bode(sys2)
title('Boost Converter with Best Controller')
margin(sys2)
