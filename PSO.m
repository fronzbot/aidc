% Kevin Fronczak
% aidc
% PSO.m
% 2013.07.08
close all
clear
tau = 1e-6; % 1 MHz

sheetR = 100;       % 100 Ohms/sq
layerC = 50e-15;    % 50 fF/um^2

bound.R.low  = 1;
bound.R.high = 100;
bound.C.low  = 1;
bound.C.high = 100;

c1 = 0.7;
c2 = 0.6;

iterMax = 20;

S = 100;
gBest = [1000, 1000];
for i = 1:S
    % Initialize particle position
    p(i).rsize = unifrnd(bound.R.low, bound.R.high);
    R = sheetR*p(i).rsize;
    C = tau/R;
    p(i).csize = C/layerC;
    
    p(i).best = [p(i).rsize, p(i).csize];
    
    if psoFit(p(i).best) < psoFit(gBest) && p(i).best(1) > 0 && p(i).best(2) > 0
        gBest = p(i).best;
    end
    
    % Initialize particle velocity
    p(i).Rvel = unifrnd(-abs(bound.R.high-bound.R.low), abs(bound.R.high-bound.R.low));
    p(i).Cvel = unifrnd(-abs(bound.C.high-bound.C.low), abs(bound.C.high-bound.C.low));
    
end
partBestR = zeros(iterMax,S);
partBestC = zeros(iterMax,S);
for j = 1:iterMax
    for i = 1:S
        % Update velocity and position
        if mod(j,2) == 0
            p(i).Rvel  = p(i).Rvel + c1*rand()*(p(i).best(1)-p(i).rsize) + c2*rand()*(gBest(1) - p(i).best(1));
            p(i).rsize = p(i).rsize + p(i).Rvel;
            R = sheetR*p(i).rsize;
            C = tau/R;
            p(i).csize = C/layerC;
        else
            p(i).Cvel  = p(i).Cvel + c1*rand()*(p(i).best(2)-p(i).csize) + c2*rand()*(gBest(2) - p(i).best(2));
            p(i).csize = p(i).csize + p(i).Cvel;
            C = layerC*p(i).csize;
            R = tau/C;
            p(i).rsize = R/sheetR;
        end
        
        if p(i).rsize < 0
            p(i).rsize = 1000;
        end
        if p(i).csize < 0
            p(i).csize = 1000;
        end
        
        % Find fitness and update best
        if psoFit([p(i).rsize, p(i).csize]) < psoFit(p(i).best)
            p(i).best = [p(i).rsize, p(i).csize];
        end
        if psoFit(p(i).best) < psoFit(gBest)
            gBest = p(i).best;
        end
        partBestR(j,i) = p(i).best(1);
        partBestC(j,i) = p(i).best(2);
    end
end

for j = 1:iterMax
   figure(j)
   scatter(partBestR(j,:), partBestC(j,:), '.')
   xlabel('R [squares]')
   ylabel('C [um^2]')
   axis([0, 1000, 0, 1000])
end
fprintf('Rsize = %.3g \t Csize = %.3g\n', gBest(1), gBest(2))


r = linspace(1,100,2000);
R = sheetR.*r;
C = tau./R;
c = C./layerC;

F = zeros(100,100);
for i = 1:length(r)
    for j = 1:length(c)
        F(i,j) = 1/(r(i)/100 + c(j)/100);
    end
end

surf(F)
