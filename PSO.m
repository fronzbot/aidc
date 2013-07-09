% Kevin Fronczak
% aidc
% PSO.m
% 2013.07.08

function [bestR, bestC] = PSO(tfCoeff)

bound.R.low  = 1;
bound.R.high = 100;
bound.C.low  = 1;
bound.C.high = 100;

c1 = 0.7;
c2 = 0.6;

sheetR = 5e3;       % Estimated Sheet Resistance of HiResPoly
                        % Assumes 1 square = 2um x 2um (reflected in
                        % fitness function)
layerC = 1e-15;     % Estimated Value for Capacitance per um^2 of poly
tau = tfCoeff;

iterMax = 20;

S = 200;
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

% for j = 1:iterMax
%    figure(j)
%    scatter(partBestR(j,:), partBestC(j,:), 'k.')
%    xlabel('R [squares]')
%    ylabel('C [um^2]')
%    axis([0, 1000, 0, 1000])
% end

bestR.size = gBest(1);
bestR.val  = gBest(1)*sheetR;
bestC.size = gBest(2);
bestC.val  = gBest(2)*layerC;


end

