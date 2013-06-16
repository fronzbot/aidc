% Kevin Fronczak
% aidc
% fitness.m
% 2013.06.16

function [ fitValue ] = fitness( num, den, RT, RB, Gain )
%This function places each system into the switched converter and evaluates
% the fitness value for each based on experimentally gathered data. 

% Define the transfer function of the switched converter
% The following is for a ideal boost converter operating in DCM
R  = 1;
L  = 18e-6;
C  = 4.7e-6;
Vo = 5.5;
Vs = 2.75;
Fs = 350e3;

D = sqrt(2*Vo*L*Fs/R)*sqrt(Vo-Vs)/Vs;
t = L*Fs/R;
M = 1/2*(1+sqrt(1+2*D^2/t));
K = M*t;

Gdo = 2*Vo/(1+D);
wz1 = 2*K^2/(D^2*L/R*(D/2-D-K/D));
wo = 1/sqrt(L*C)*sqrt((4*K^2*D+4*K^2)/(D^4+4*D^2*K+4*K^2));
Q = 4*K^2*(D+1)/wo * 1/(4*R*C*D*K^2+L/R*(D^4+4*D^2*K+4*K^2)+L/R*D^3);

top = [1/wz1 1];
bot = [1/wo^2 1/(Q*wo) 1];
boost = Gdo*tf(top,bot);

% Begin constructing each system and analyze the fitness
total = length(num);
power = (Vo^2./(RT+RB)).';

G   = zeros(1,total);
BW  = zeros(1,total);
Pm  = zeros(1,total);

for i=1:total
    % Construct the system
    sys = boost*Gain(i)*tf(num(i,:), den(i,:))*1/2.5; % 2.5 is peak value of ramp input to PWM generator for VMC
    
    % Get DC gain, bandwidth, and phase margin
    G(i)  = abs(20*log10(dcgain(sys)));
    BW(i) = bandwidth(sys);
    if BW(i) >= 1e6
        BW(i) = 1/BW(i);
    end
    [~, marg, ~, ~] = margin(sys);
    Pm(i) = marg;
    if Pm(i) >= 90
        Pm(i) = 0; % margin returns >90 degrees when systems are unstable
    end
end

% Calculate fitness

fitValue = (17.*Pm - 290) ...
          -(69.*log(power)+900) ...
          +0.01.*G.^2 ...
          +10.*log(BW)-1500;

