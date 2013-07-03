% Calculate parameters based on parabolic equation
close all
clear
pm   = linspace(-360, 360, 100)./180;
gain = linspace(-1e3, 1e4, 100)./1e4;
tr   = 1e-9./linspace(1e-9,1e-3,100);
os   = linspace(-200,200,100)./100;

[PMos, Gtr] = meshgrid(pm, os);


f_PM = -(PMos-76/180).^2+100;
f_G  = -(Gtr-5/100).^2+100;

f_pm = -0.8.*(pm-76).^2+1000;
f_g  = -(gain-6000).^2+500;


%[X, Y] = meshgrid(-50:50,-50:50);
%F = -(X.^2)-(Y.^2);
F = f_PM+f_G;
fitValue = f_pm+f_g;

figure
surf(PMos ,os, F)
xlabel('\phi_M')
ylabel('Overshoot')
colormap jet
