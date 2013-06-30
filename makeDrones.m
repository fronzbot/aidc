% Kevin Fronczak
% aidc
% makeDrones.m
% 2013.06.28

function [drone] = makeDrones(Vout, Vref, gm, children)
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
% Ro and RT (which will then change RB)
%
% Once the transfer function type is determined the coefficient values are
% selected.  This is done  multiple times as determined by the variable 
% 'children'.  Since many parameters can be modified, a mask is applied 
% to the coefficients such that anywhere from 1 to all of the coefficients 
% will be modified between subsequent children.
%
% The final step in initialization is to determine the fitness of each
% child using the fitness function defined in fitness.m

for c = 1:children
    % Randomize pole and zero count (choose transfer function type)
    drone(c).Gpn = randi(3,1)+1;
    drone(c).Gzn = randi(3,1);

    % Note that there cannot be more zeros than poles, so clamp the number of
    % zeros to satisfy this condition.
    if drone(c).Gzn > drone(c).Gpn
        drone(c).Gzn = drone(c).Gpn;
    end

    % Loop through number of poles and zeros and randomly assign coefficients
    % For initialization, the coefficients are distubted evenly across the
    % spectrum of 1Hz to 500kHz.
    drone(c).Gzc = zeros(1,drone(c).Gzn);
    drone(c).Gpc = zeros(1,drone(c).Gpn);
    for i = 1:drone(c).Gzn
        if i ~= drone(c).Gzn
            randFreq = (randi(9)+rand())*10^(randi(6));
            drone(c).Gzc(i) = 1./(2*pi*randFreq);
        else
            drone(c).Gzc(i) = 1;
        end
    end
    for i = 1:drone(c).Gpn
        if i ~= drone(c).Gpn
            randFreq = (randi(9)+rand())*10^(randi(6));
            drone(c).Gpc(i) = 1./(2*pi*randFreq);
        else
            drone(c).Gpc(i) = 1;
        end
    end

    drone(c).age = 1;
    drone(c).gm  = gm;
    drone(c).Vo  = Vout;
    drone(c).Grt = randi(10e6, 1);
    drone(c).Grb = Vref*drone(c).Grt/(Vout-Vref);
    drone(c).Gro = randi(50e3, 1);
end

end

