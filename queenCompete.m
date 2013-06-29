% Kevin Fronczak
% aidc
% queenCompete.m
% 2013.06.28

function [ bestBee ] = queenCompete(queen1, queen2)
%This function compares the fitness of two bees and returns the best

if fitness(queen1) >= fitness(queen2)
    bestBee = queen1;
else
    bestBee = queen2;
end

end