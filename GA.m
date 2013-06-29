% Kevin Fronczak
% aidc
% GA.m
% 2013.06.28

function [bestQueen] = GA(queen, drone, Vout, Vref)
%GA is the genetic algorithm that finds the queen bee and
% creates new bees by mating them with drones.  The new virgin
% queens are then evaluated and the best is selected as the new
% queen bee.
genes = {'Gpc', 'Gzc', 'Gpn', 'Gzn', 'Gro', 'Grt'};
for i = 1:length(drone)
    % Randomly pick the number of crossover genes
    geneCount = length(genes);
    geneIndex = randsample(geneCount,randi(geneCount));
    
    newQueen(1).gm = drone(i).gm;
    newQueen(2).gm = drone(i).gm;
    newQueen(1).Vo = drone(i).Vo;
    newQueen(2).Vo = drone(i).Vo;
    
    % Begin crossover and mutation
    for j = 1:geneCount
        % If the gene is in the crossover pool
        if ismember(j,geneIndex)
            % Check if gene undergoes mutation
            if rand(1) <= 0.02
                newQueen(1).(genes{j}) = mutateGene(drone(i), genes{j});
                newQueen(2).(genes{j}) = mutateGene(queen, genes{j});
            else
                newQueen(1).(genes{j}) = drone(i).(genes{j});
                newQueen(2).(genes{j}) = queen.(genes{j});
            end
        else
            % Check if gene undergoes mutation
            if rand(1) <= 0.02
                newQueen(1).(genes{j}) = mutateGene(queen, genes{j});
                newQueen(2).(genes{j}) = mutateGene(drone(i), genes{j});
            else
                newQueen(1).(genes{j}) = queen.(genes{j});
                newQueen(2).(genes{j}) = drone(i).(genes{j});
            end
        end
        
        % Update Grb if Grt was modified
        if strcmp(genes{j}, 'Grt')
            newQueen(1).Grb = Vref*newQueen(1).Grt/(Vout-Vref);
            newQueen(2).Grb = Vref*newQueen(2).Grt/(Vout-Vref);
        end
        
        % Update coefficients if Gzn or Gpn were modified
        for k = 1:2
            if strcmp(genes{j}, 'Gzn')
                if newQueen(k).Gzn > newQueen(k).Gzp
                    newQueen(k).Gzn = newQueen(k).Gzp;
                end
                while length(newQueen(k).Gzc) < newQueen(k).Gzn
                    newQueen(k).Gzc(end+1) = 1./(2*pi*randi(500e3,1));
                end
                while length(newQueen(k).Gzc) > newQueen(k).Gzn 
                    newQueen(k).Gzc = newQueen(k).Gzc(1:end-1);
                end
            end
            if strcmp(genes{j}, 'Gpn')
                while length(newQueen(k).Gpc) < newQueen(k).Gpn
                    newQueen(k).Gpc(end+1) = 1./(2*pi*randi(500e3,1));
                end
                while length(newQueen(k).Gpc) > newQueen(k).Gpn
                    newQueen(k).Gpc = newQueen(k).Gpc(1:end-1);
                end
            end
            
        end
    end % End Gene Count For Loop
    newQueen(1).age = 1;
    newQueen(2).age = 1;
    virginQueen(i) = queenCompete(newQueen(1), newQueen(2));
    
end % End Drone For Loop

% Have all queens compete for nest dominance
virginQueen(i).age = 1;
bestQueen = virginQueen(i);
for i = 2:length(virginQueen)
    bestQueen = queenCompete(bestQueen, virginQueen(i));
end

end

