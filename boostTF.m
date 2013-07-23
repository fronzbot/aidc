% Kevin Fronczak
% aidc
% boostTF.m
% 2013.06.28

function [sys] = boostTF()
% Boost DCM ideal TF
R  = 300;
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
sys = Gdo*tf(top,bot);
end