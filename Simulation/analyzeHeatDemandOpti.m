function [dotQHeat,QHeat,TRoom,dotQHeatInput,Tamb]=analyzeHeatDemandOpti(target,nsims)
%Change to the target folder
cd(target);

%Load the data (up to now, an output time step of 900 s has to be used)
for k=1:nsims
    %result files must be named with dsres_*.mat with * as placeholder for
    %subsequent numbers
    filename = ['dsres_' num2str(k) '.mat'];
    data = dymload(filename);

    dummy=dymget(data,'QHeat');
    QHeat(:,k)=dummy;
    dummy=dymget(data,'dotQHeat');
    dotQHeat(:,k)=dummy;
    dummy=dymget(data,'dotQHeatInput');
    dotQHeatInput(:,k)=dummy;
    dummy=dymget(data,'TRoom');
    TRoom(:,k)=dummy;
    dummy=dymget(data,'TAmb');
    Tamb(:,k)=dummy; 
end

