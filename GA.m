% Kevin Fronczak
% aidc
% GA.m
% 2013.06.16

function [allZeros, allPoles, allRo, allRT, allRB] = GA( parentZeros, parentPoles, parentRo, parentRT, parentRB, gm, children )
%GA is the genetic algorithm that creates new genes from best parents from
% last generation.  This function first randomly selects the genes to
% crossover via a bit mask, breads a given number of children, and then
% returns those children for external evaluation.

% Create arrays for each parameter based on number of defined children
zeroCount = length(parentZeros(1,:));
poleCount = length(parentPoles(1,:));
allRT     = zeros(children, 1);
allRB     = zeros(children, 1);
allRo     = zeros(children, 1);
allK      = zeros(children, 1);

% Check if number of poles and zeros should mutate
mutatePoles = randi(2)-1;
mutateZeros = randi(2)-1;

if mutatePoles == 1
    poleCount = randi(3,1)+1;
end
if mutateZeros == 1
    zeroCount = randi(3,1);
end

if poleCount < zeroCount
    poleCount = zeroCount;
end

allZeros  = zeros(children, zeroCount);
allPoles  = zeros(children, poleCount);

if zeroCount > length(parentZeros(1,:))
    parentZeros(1,zeroCount) = 0;
    parentZeros(2,zeroCount) = 0;
elseif zeroCount < length(parentZeros(1,:))
    parentZeros = parentZeros(:,1:zeroCount);
end

if poleCount > length(parentPoles(1,:))
   parentPoles(1,poleCount) = 0;
   parentPoles(2,poleCount) = 0;
elseif poleCount < length(parentPoles(1,:))
    parentPoles = parentPoles(:,1:poleCount);
end



% Determine which genes are inhertied from which parents.
% Any gene that does not get transmitted to a child (ie. the 
% value is equal to zero) gets randomly selected via a normal
% distribution with a random parent chosen as the mean.  Any 
% gene that gets inherited from each parent is taken as the average. 
for i = 1:children
    % First work with zeros of transfer function
    mask1 = fix(rand(1,zeroCount));
    mask2 = fix(rand(1,zeroCount));

    newCoeffs = (parentZeros(1,1:zeroCount).*mask1+parentZeros(2,1:zeroCount).*mask2)/2;
    
    for j = 1:zeroCount
        if newCoeffs(j) == 0
            mean  = parentZeros(randi(2,1),j);
            sigma = mean/4;
            newCoeffs(j) = normrnd(mean, sigma);
        end
    end
    allZeros(i,:) = newCoeffs;

    
    % Next work with poles of transfer function
    mask1 = fix(rand(1,poleCount));
    mask2 = fix(rand(1,poleCount));
    
    newCoeffs = (parentPoles(1,1:poleCount).*mask1+parentPoles(2,1:poleCount).*mask2)/2;
    
    for j = 1:poleCount
        if newCoeffs(j) == 0
            mean  = parentPoles(randi(2,1),j);
            sigma = mean/4;
            newCoeffs(j) = normrnd(mean, sigma);
        end
    end
    allPoles(i,:) = newCoeffs.';
    
    % Mutate RT?
    mask1 = fix(randi(2,1)-1);
    mask2 = fix(randi(2,1)-1);
    allRT(i) = (parentRT(1,:).*mask1+parentRT(2,:).*mask2)/2;
    if allRT(i) == 0
        mean  = parentRT(randi(2,1));
        sigma = mean/4;
        allRT(i) = normrnd(mean,sigma);
    end
    
    % Mutate RB?
    mask1 = fix(randi(2,1)-1);
    mask2 = fix(randi(2,1)-1);
    allRB(i) = (parentRB(1,:).*mask1+parentRB(2,:).*mask2)/2;
    if allRB(i) == 0
        mean  = parentRB(randi(2,1));
        sigma = mean/4;
        allRB(i) = normrnd(mean,sigma);
    end
    
    % Mutate Ro?
    mask1 = fix(randi(2,1)-1);
    mask2 = fix(randi(2,1)-1);
    allRo(i) = (parentRo(1,:).*mask1+parentRo(2,:).*mask2)/2;
    if allRo(i) == 0
        mean  = parentRo(randi(2,1));
        sigma = mean/4;
        allRo(i) = normrnd(mean,sigma);
    end
    allK(i)  = gm*allRo(i)*allRB(i)/(allRT(i)+allRB(i));
end % End child creation

end

