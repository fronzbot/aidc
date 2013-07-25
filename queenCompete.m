% Kevin Fronczak
% aidc
% queenCompete.m
% 2013.06.28

function [ bestBee ] = queenCompete(queen1, queen2, opts)
%This function compares the fitness of two bees and returns the best

if fitness(queen1, opts) > fitness(queen2, opts)
    bestBee = queen1;
else
    bestBee = queen2;
end

end