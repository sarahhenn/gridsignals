%%
function [nsims]=simulateHeatDemandOpti(target,targetInput,model,numberOfCores,occ)

targetInput=strrep(targetInput,'\','/');

models={};

for k=1:numberOfCores
    models=[models;[model,'(occupancyTable.fileName=\"',targetInput,'/occupancySim_',num2str(k),'.mat\")']];
end

%%
parNames={'Tset[1].k','nairInfilt[1].k','multizone.zoneParam[1].nrPeople'};
valuesTotal=[];
distVector=randn(size(occ,2),2);
valuesTotal(:,1)=294.15+0.5*distVector(:,1);

valuesTotal(:,2)=0.15+0.05*distVector(:,2);
% occ=load('D:\MeineDaten\Stipendium\Paper_Evaluation\LV_suburban_profiles.mat','occ');
valuesTotal(:,3)=(max(occ))';
nsims=size(valuesTotal,1);

%Calculate how many simulations are performed with which model (similar
%formulation in parallelSimulationMATLAB
% idxTotal=1:nsims;
idxTotal=1:nsims;
nsims_per_core_max=ceil(size(idxTotal,2)/numberOfCores);
for k=1:numberOfCores
    if k<=mod(size(idxTotal,2),numberOfCores)|| mod(size(idxTotal,2),numberOfCores)==0
        nsims_per_core(k)=nsims_per_core_max;
    else
        nsims_per_core(k)=nsims_per_core_max-1;
    end
end
nsims_per_core=[0,nsims_per_core];
for k=1:numberOfCores
%     if k<=mod(nsims*size(userTypes,1),numberOfCores)
    indices=(sum(nsims_per_core(1:k))+1:sum(nsims_per_core(1:k+1)))';
    parameters{k}.names=parNames;
    parameters{k}.values=valuesTotal(indices,:);
    parameters{k}.indices=idxTotal(indices);
end
% 
% parameters{1}.names=parNames;
% parameters{1}.values=valuesTotal;
% parameters{1}.indices=idxTotal;

%%
optionsCreate.startTime=-7*86400;
optionsCreate.stopTime=365*86400;
optionsCreate.stepSize=900;
optionsCreate.solver=8;
optionsCreate.justOutputs=1;
optionsCreate.withParameterOutput=0;
optionsCreate.useLog=1;
optionsCreate.maxTimeStep=60;
timestamp=clock;
timestamp=num2str(timestamp);
timestamp=timestamp(~isspace(timestamp));
timestamp(end-3:end)=[];

save([target,'\variablesCreate.mat'],'target','models','optionsCreate','parameters','valuesTotal','parNames','-v7.3');
% numberOfCoresShort=4;
% parametersShort=parameters(1:numberOfCoresShort);
[~,~] = createDsin(target,models,parameters,optionsCreate);
% [~,~] = createDsin(target,modelsShort,parameters,optionsCreate);

% warning('createDsin uncommented!');


%%
startIdx=1;
endIdx=nsims;
modelNr=ones(size(valuesTotal,1),1);

optionsSim.startNew=0;
optionsSim.showStatus=1;
optionsSim.withFileVariation=1;
optionsSim.sourceFile{1}=[targetInput,'/occupancy_'];
optionsSim.destFile{1}=[targetInput,'/occupancySim_'];

% 
optionsSim.singleSimulations=0;
optionsSim.indices=1:endIdx;

timestamp=clock;
timestamp=num2str(timestamp);
timestamp=timestamp(~isspace(timestamp));
timestamp(end-3:end)=[];


save([target,'\variablesSim_',timestamp,'.mat'],'target','numberOfCores','startIdx','endIdx','modelNr','optionsSim','-v7.3');

[test1]=parallelSimulationMATLAB(target,numberOfCores,startIdx,endIdx,modelNr,optionsSim);

% toc
done=1;

