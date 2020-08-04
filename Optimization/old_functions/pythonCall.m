%%
target='D:\Ergebnisse\TestParallel\';
model='CityDistrictAnalysis.Systems.CHP_GCB_House_WeatherComb';
nsims=60;
numberOfCores=12;
models={};
%generation of 'numberOfCores' models that are passed to the "createDSIN"
%method
for k=1:numberOfCores  
    models=[models;[model,'(pathHeatDemand = \"D:/Ergebnisse/TestParallel/HeatDemandFiles/HeatDemandSim_',num2str(k),'.mat\")']];
end

%%
%simple constant heat demand profiles for DHW (for testing)
modelNr=repmat((1:numberOfCores)',ceil(nsims/numberOfCores),1);
for k=1:nsims
    heatDemand(:,1)=(0:60:31536000)';
    heatDemand(:,2)=k*1e3; %from l/h to l/s to kg/s to W/K to W
    save([target,'\HeatDemandFiles\HeatDemand_',num2str(k),'.mat'],'heatDemand','-v4');
end

%%
idxTotal=1:nsims;
%calculation how many simulations per core should be executed (is necessary
%for the assignment of the single simulations to the cores/processes)
nsims_per_core_max=ceil(size(idxTotal,2)/numberOfCores);
for k=1:numberOfCores
    if k<=mod(size(idxTotal,2),numberOfCores)|| mod(size(idxTotal,2),numberOfCores)==0
        nsims_per_core(k)=nsims_per_core_max;
    else
        nsims_per_core(k)=nsims_per_core_max-1;
    end
end

%parameters that should be varied and a vector (or matrix) of values for
%these parameters
parNames={'airExchange.k'};
parValues=(0.01:0.01:0.6)';
nsims_per_core=[0,nsims_per_core];
for k=1:numberOfCores
%     if k<=mod(nsims*size(userTypes,1),numberOfCores)
    indices=(sum(nsims_per_core(1:k))+1:sum(nsims_per_core(1:k+1)))';
    parameters{k}.names=parNames;
    parameters{k}.values=parValues(indices,:);
    parameters{k}.indices=idxTotal(indices);
end


%%

%process of creating different dsin-files 
%setting options first
optionsCreate.startTime=0;
optionsCreate.stopTime=14*86400;
optionsCreate.maxTimeStep=60;
% warning('change simulation time!');

optionsCreate.stepSize=900;
optionsCreate.solver=8;
optionsCreate.justOutputs=1;
optionsCreate.withParameterOutput=0;
optionsCreate.useLog=1;

%generation of dsin-files according to the models (model has to be opened)
[~,~] = createDsin(target,models,parameters,optionsCreate);




%%
%The folder
calcFolder='D:\EBC_SVN\projects\EBC0084_PTJ_NetzreaktiveGebauder_ssi\Python\ParallelSimulation';
evalString=['"C:\WinPython-64bit-3.4.3.5\python-3.4.3.amd64\python.exe" ',calcFolder,'\parallelSimulationPython.py '];

targetPython='"D:\\Ergebnisse\\TestParallel\\" ';
vectorSimulations=strjoin(arrayfun(@(x) num2str(x),1:nsims,'UniformOutput',false),',');
vectorModels=strjoin(arrayfun(@(x) num2str(x),modelNr','UniformOutput',false),',');
[message,done]=system([evalString,num2str(numberOfCores),' ',targetPython,vectorSimulations,' ',vectorModels,' 1']);