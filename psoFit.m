function [fitVal] = psoFit(pBest)
    fitVal = abs(pBest(1))/4 + abs(pBest(2)); 
end