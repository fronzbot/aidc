function [fitVal] = psoFit(pBest)
    fitVal = abs(pBest(1))/100 + abs(pBest(2))/100; 
end