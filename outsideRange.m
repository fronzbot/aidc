function [outOfRange] = outsideRange(val, min, max)
%Returns true if val is not in between min and max
if val >= min && val <= max
    outOfRange = false;
else
    outOfRange = true;
end