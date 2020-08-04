function [A,B,C,D] = R2C2_red(par, T0, T)

UAie = par(1) * 1000;   % Converting kW/K to W/K (kW is used in order to keep a better numerical conditioning of the problem)
UAea = par(2) * 1000;
Ci   = par(3) * 3.6e6;  % Converting kWh to J (kWh is used in order to keep a better numerical conditioning of the problem)
Ce   = par(4) * 3.6e6;
Gi    = par(5);


A = [-UAie/Ci, UAie/Ci	; UAie/Ce, -(UAie+UAea)/Ce ];
B = [0, Gi/Ci, 1/Ci	; UAea/Ce, 0, 0];

C = [1, 0];
D = [0, 0, 0];


K = [0];
x0 = T0;

end

