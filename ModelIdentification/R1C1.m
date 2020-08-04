function [A,B,C,D,K,x0] = R1C1(par, T0, T)

UA  = par(1) * 1000;    % Converting kW/K to W/K (kW is used in order to keep a better numerical conditioning of the problem)
C   = par(2) * 3.6e6;   % Converting kWh to J (kWh is used in order to keep a better numerical conditioning of the problem)
Aw   = par(3);

A = [-UA/C];
B = [UA/C, Aw/C, 1/C, 1/C,1/C];
C = [1];
D = [0, 0, 0, 0,0];

K = [0];
x0 = T0;

end

