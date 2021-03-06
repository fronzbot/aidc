% Kevin Fronczak
% aidc
% mutateGene.m
% 2013.06.28

function [ newGene ] = mutateGene(bee, origGene)
    if strcmp(origGene, 'Gpc')
        newGene = zeros(1, bee.Gpn);
        for i = 1:bee.Gpn
            if i == bee.Gpn
                newGene(i) = 1;
            else
                randFreq = (randi(9)+rand())*10^(randi(6));
                newGene(i) = 1./(2*pi*randFreq);
            end
        end

    elseif strcmp(origGene, 'Gzc')
        newGene = zeros(1, bee.Gzn);
        for i = 1:bee.Gzn
            if i == bee.Gzn
                newGene(i) = 1;
            else
                randFreq = (randi(9)+rand())*10^(randi(6));
                newGene(i) = 1./(2*pi*randFreq);
            end
        end
    
    elseif strcmp(origGene, 'Gpn')
        newGene = randi(3,1)+1;
      
    elseif strcmp(origGene, 'Gzn')
        newGene = randi(3,1);
        
    elseif strcmp(origGene, 'Gro')
        newGene = randi(50e3, 1);
        
    elseif strcmp(origGene, 'Grt')
        newGene = randi(10e6, 1);
    end
end