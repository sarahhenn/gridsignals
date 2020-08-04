function [A,B,C,D] = R3C2(par, T0, T)

UAia = par(1) * 1000;   % Converting kW/K to W/K (kW is used in order to keep a better numerical conditioning of the problem)
UAie = par(2) * 1000;
UAea = par(3) * 1000;
Ci   = par(4) * 3.6e6;  % Converting kWh to J (kWh is used in order to keep a better numerical conditioning of the problem)
Ce   = par(5) * 3.6e6;
Aw    = par(6);

A = [-(UAie+UAia)/Ci, UAie/Ci    	; UAie/Ce, -(UAie+UAea)/Ce ];
B = [UAia/Ci, Aw/Ci, 1/Ci, 1/Ci, 1/Ci; UAea/Ce, 0, 0, 0, 0 ];

C = [1, 0];
D = [0, 0, 0, 0, 0];

% K = [0 , 0; 0 , 0];
x0 = T0;

end

