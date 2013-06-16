% Kevin Fronczak
% aidc
% initialization.m
% 2013.06.16

function [zerosToPass, polesToPass, RoToPass, RTToPass, RBToPass] = initialization(Vout, Vref, gm, children)
%This function initializes GA used for the converter controller
% The transfer function for the DC converter is defined in fitness.m
% First, the function randomly chooses a control type of the following
% structures:
%  (s/wz1 + 1)        (s/wz1 + 1)                    (s/wz1 + 1)
%  ----------- ; ---------------------- ; ---------------------------------
%  (s/wp1 + 1)   (s/wp1 + 1)(s/wp2 + 1)   (s/wp1 + 1)(s/wp2 + 1)(s/wp2 + 1)
%
%  (s/wz1 + 1)(s/wz2 + 1)        (s/wz1 + 1)(s/wz2 + 1)
%  ---------------------- ; ---------------------------------
%  (s/wp1 + 1)(s/wp2 + 1)   (s/wp1 + 1)(s/wp2 + 1)(s/wp2 + 1)
%
% However, to allow more flexibility, the equations are reduced such that
% coefficients can be modified as follows:
%
%   sa1 + a0          sa1 + a0                  sa1 + a0
%  ----------- ; ------------------- ; --------------------------
%   sb1 + b0      s^2b2 + sb1 + b0      s^3b3 + s^2b2 + sb1 + b0
%
%   s^2a2 + sa1 + a0         s^2a2 + sa1 + a0
%  ------------------ ; --------------------------
%   s^2b2 + sb1 + b0     s^3b3 + s^2b2 + sb1 + b0
%
% There is also a gain term, K, which is defined as K = gmRo*RB/(RT+RB)
% In this application, gm is defined values and will not
% change, thus the only way to modify the gain is to modify the value for
% Ro an RT (which will then change RB)
%
% Once the transfer function type is determined the coefficient values are
% selected.  This is done  multiple times as determined by the variable 
% 'children'.  Since many parameters can be modified, a mask is applied 
% to the coefficients such that anywhere from 1 to all of the coefficients 
% will be modified between subsequent children.
%
% The final step in initialization is to determine the fitness of each
% child using the fitness function defined in fitness.m

% Randomize pole and zero count (choose transfer function type)
poleCount = randi(3,1)+1;
zeroCount = randi(3,1);

% Note that there cannot be more zeros than poles, so clamp the number of
% zeros to satisfy this condition.
if zeroCount > poleCount
    zeroCount = poleCount;
end

% Loop through number of poles and zeros and randomly assign coefficients
% For initialization, the coefficients are distubted evenly across the
% spectrum of 1Hz to 500kHz.
zeroCoeffs = zeros(1,zeroCount);
poleCoeffs = zeros(1,poleCount);
for i = 1:zeroCount
    if i ~= zeroCount
        zeroCoeffs(i) = 1./(2*pi*randi(500e3,1));
    else
        zeroCoeffs(i) = 1;
    end
end
for i = 1:poleCount
    if i ~= poleCount
        poleCoeffs(i) = 1./(2*pi*randi(500e3,1));
    else
        poleCoeffs(i) = 1;
    end
end

% Randomly generate gain value from gm, RT, and RB
% Verify that gm is a negative quantity (if not, make it negative)
if gm > 0
    gm = -1*gm;
end

RT = randi(100e6, 1);
RB = Vref*RT/(Vout-Vref);
Ro = randi(100e3, 1);

% Create arrays for each parameter based on number of defined children
tfN    = zeros(children, zeroCount);
tfD    = zeros(children, poleCount);
RTvals = zeros(children, 1);
RBvals = zeros(children, 1);
Rovals = zeros(children, 1);
Kvals  = zeros(children, 1);

% Place already found values into appropriate array
tfN(1,:)  = zeroCoeffs;
tfD(1,:)  = poleCoeffs;
RTvals(1) = RT;
RBvals(1) = RB;
Rovals(1) = Ro;
Kvals(1)  = gm*Ro*RB/(RB+RT);

% Loop through and create initial population
% For each child, randomly select which parameters to pass from initial
% parent (that is, the first row of each array).
for i = 2:children
    % First work with zeros of transfer function
    mask = fix(rand(1,zeroCount));
    newCoeffs = tfN(1,:).*mask;
    for j = 1:zeroCount
        if newCoeffs(j) == 0
            newCoeffs(j) = 1/(2*pi*randi(500e3,1));
        end
    end
    tfN(i,:) = newCoeffs;
    
    % Next work with poles of transfer function
    mask = fix(rand(1,poleCount));
    newCoeffs = tfD(1,:).*mask;
    for j = 1:poleCount
        if newCoeffs(j) == 0
            newCoeffs(j) = 1/(2*pi*randi(500e3,1));
        end
    end
    tfD(i,:) = newCoeffs;
    
    % Gain Value
    RTvals(i) = randi(100e6, 1);
    RBvals(i) = Vref*RT/(Vout-Vref);
    Rovals(i) = randi(100e3, 1);
    Kvals(i)  = gm*Rovals(i)*RBvals(i)/(RTvals(i)+RBvals(i));
end % End child creation

% Get fitness of each function
fits = fitness(tfN, tfD, RTvals, RBvals, Kvals);

% Find top two performing functions
[~, indices] = sort(fits(:), 'descend');
parent1 = indices(1);
parent2 = indices(2);

zerosToPass = [tfN(parent1);    tfN(parent2)];
polesToPass = [tfD(parent1);    tfD(parent2)];
RoToPass    = [Rovals(parent1); Rovals(parent2)];
RTToPass    = [RTvals(parent1); RTvals(parent2)];
RBToPass    = [RBvals(parent1); RBvals(parent2)];

end

