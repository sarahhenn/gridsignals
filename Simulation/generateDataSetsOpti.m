%%
%set all necessary file and folder names

% % % fileProfiles='D:\MeineDaten\Stipendium\Paper_Evaluation\Input\LV_suburban_profiles.mat'; %data sets for LV profiles
fileProfiles='D:\MeineDaten\Stipendium\Paper_Evaluation\Input\MV_profiles_opti.mat'; %data sets for MV profiles with 100 % PV and 100 % Wind

% % % fileGridSignals='D:\MeineDaten\Stipendium\Paper_Evaluation\output\grid_signals_LV_suburban_PV_100.mat'; %LV grid with 100 % PV
fileGridSignals='D:\MeineDaten\Stipendium\Paper_Evaluation\output\grid_signals_MV_rural_suburban_PV_100_WES_100.mat'; %LV grid with 100 % PV


% % % fileCO2='D:\MeineDaten\Stipendium\Paper_Evaluation\Input\co2_factor_20.mat'; %CO2 profile with double capacity of renewables (without electrification)#
fileCO2='D:\MeineDaten\Stipendium\Paper_Evaluation\Input\co2_factor_20_ELEC.mat'; %CO2 profile with double capacity of renewables (without electrification)#


% % % destFolderInputOpti='D:\Ergebnisse\Optimization_Evaluation_2030_LV\InputData';
destFolderInputOpti='D:\Ergebnisse\Optimization_Evaluation_2030_ELEC_MV\InputData';

destFolderSim='D:\Ergebnisse\Optimization_Evaluation\Simulation_MV';
addpath('D:\GIT\evaluation_optimization\Simulation');
addpath('D:\EBC_SVN\MatLab\library\parameter_variation');
addpath(genpath('C:\Program Files (x86)\Dymola 2017\Mfiles'));

grid='MV';

folderInputDataSimulation=[destFolderSim,'\InputData'];
%%
%load all necessary data sets from profiles
load(fileProfiles,'occ','el_dem');
nAir=double(occ)*0.3;
for k=1:size(occ,2)
    relOcc(:,k)=double(occ(:,k))/max(double(occ(:,k)));
    intGains(:,k)=el_dem(:,k)*0.8;
    occupancy=double([(0:900:31536000-1)',relOcc(:,k),nAir(:,k),intGains(:,k)]);
    save([folderInputDataSimulation,'\occupancy_',num2str(k),'.mat'],'occupancy','-v4');
end


%%
[nsims]=simulateHeatDemandOpti(destFolderSim,folderInputDataSimulation,'OFD_Calculations.Residential2009',4,occ);

%%
%loading the heat demand data sets
[dotQHeat,QHeat,TRoom,~,Tamb]=analyzeHeatDemandOpti([destFolderSim,'\results'],nsims);
dotQHeat=dotQHeat(end-35040:end,:); %removing the data that is only necessary for initialization of all walls etc.
dotQHeat=dotQHeat/1000; %conversion to kW

%conversion of ambient temperature
Tamb=Tamb-273.15; %conversion to °C

%%
%loading DHW data
clear dhw
load(fileProfiles,'dhw');
%loaded data is in l/h (has to be converted to kW)
dhw=dhw/3600*0.95*4.187*50;
dhw=[dhw;dhw(1,:)]; %add one extra entry to be in line with the space heating demand

%loading the co2 data set
clear co2_factor; %delete it in case it was there before
load(fileCO2,'co2_factor'); %loading the co2 factor for twice the actual RES generation



%loading the grid data files (ALC and ALC per feeder)
clear p_alc_grid p_alc_feeder p_cong_grid
load(fileGridSignals,'p_alc_grid','p_alc_feeder','p_cong_grid');

%loading EV availability and demand
clear ev_occ ev_dem
load(fileProfiles,'ev_occ','ev_dem');
EVcons=zeros(size(ev_occ));
%assigning the whole demand per day to the time the car leaves the home
%(only possible since it leaves the home once a day)
for n=1:size(ev_occ,2)
    idxOff=find(diff(ev_occ(:,n))==-1);
    EVcons(idxOff+1,n)=ev_dem(:,n);
end
nBuildings=size(EVcons,2);

%generating data set for feeder (just 20 buildings in every part of the
%feeder)
if strcmp(grid,'LV')
    buildingFeeder=[ones(20,1);2*ones(20,1);3*ones(20,1);4*ones(20,1);5*ones(20,1);6*ones(20,1)];
else
    buildingFeeder=[ones(30,1);2*ones(30,1);3*ones(20,1);4*ones(20,1);5*ones(20,1);6*ones(20,1);7*ones(20,1);8*ones(20,1)];
end
    
%%
%Building up the scenarios

%scenario 1
storageFactors=0.2;
gridWeights=0;
co2signalTot(:,1)=mean(co2_factor(1:end-1,3))*ones(35041,1);
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies1.txt'],buildingTechnologies,'\t');

%scenario 2
storageFactors(2,1)=0.2;
gridWeights(2,1)=0;
co2signalTot(:,2)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies2.txt'],buildingTechnologies,'\t');

%scenario 3
storageFactors(3,1)=0.2;
gridWeights(3,1)=3;
co2signalTot(:,3)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies3.txt'],buildingTechnologies,'\t');

%scenario 4
storageFactors(4,1)=0.2;
gridWeights(4,1)=3;
co2signalTot(:,4)=co2_factor(1:end-1,3); %mix
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies4.txt'],buildingTechnologies,'\t');

%scenario 5
storageFactors(5,1)=1.5;
gridWeights(5,1)=3;
co2signalTot(:,5)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies5.txt'],buildingTechnologies,'\t');

%scenario 6
storageFactors(6,1)=0.2;
gridWeights(6,1)=0;
co2signalTot(:,6)=mean(co2_factor(1:end-1,3))*ones(35041,1);
buildingTechnologies=[zeros(nBuildings,2),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies6.txt'],buildingTechnologies,'\t');

%scenario 7
storageFactors(7,1)=0.2;
gridWeights(7,1)=0;
co2signalTot(:,7)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,2),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies7.txt'],buildingTechnologies,'\t');

%scenario 8
storageFactors(8,1)=0.2;
gridWeights(8,1)=3;
co2signalTot(:,8)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,2),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies8.txt'],buildingTechnologies,'\t');

%scenario 9
storageFactors(9,1)=0.2;
gridWeights(9,1)=3;
co2signalTot(:,9)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies9.txt'],buildingTechnologies,'\t');

%scenario 10
storageFactors(10,1)=0.2;
gridWeights(10,1)=0;
co2signalTot(:,10)=mean(co2_factor(1:end-1,3))*ones(35041,1);
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies10.txt'],buildingTechnologies,'\t');

%scenario 11
storageFactors(11,1)=0.2;
gridWeights(11,1)=0;
co2signalTot(:,11)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies11.txt'],buildingTechnologies,'\t');

%scenario 12
storageFactors(12,1)=0.2;
gridWeights(12,1)=3;
co2signalTot(:,12)=co2_factor(1:end-1,3); %mix
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies12.txt'],buildingTechnologies,'\t');

%scenario 13
storageFactors(13,1)=0.2;
gridWeights(13,1)=3;
co2signalTot(:,13)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies13.txt'],buildingTechnologies,'\t');

%scenario 14
storageFactors(14,1)=0.5;
gridWeights(14,1)=3;
co2signalTot(:,14)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies14.txt'],buildingTechnologies,'\t');

%scenario 15
storageFactors(15,1)=1.0;
gridWeights(15,1)=3;
co2signalTot(:,15)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[ones(nBuildings,1),zeros(nBuildings,5)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies15.txt'],buildingTechnologies,'\t');

%scenario 16
storageFactors(16,1)=0.2;
gridWeights(16,1)=0;
co2signalTot(:,16)=mean(co2_factor(1:end-1,3))*ones(35041,1); %const
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies16.txt'],buildingTechnologies,'\t');

%scenario 17
storageFactors(17,1)=0.2;
gridWeights(17,1)=0;
co2signalTot(:,17)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies17.txt'],buildingTechnologies,'\t');

%scenario 18
storageFactors(18,1)=0.2;
gridWeights(18,1)=100;
co2signalTot(:,18)=co2_factor(1:end-1,3); %mix
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies18.txt'],buildingTechnologies,'\t');

%scenario 19
storageFactors(19,1)=0.5;
gridWeights(19,1)=100;
co2signalTot(:,19)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies19.txt'],buildingTechnologies,'\t');

%scenario 20
storageFactors(20,1)=1.0;
gridWeights(20,1)=100;
co2signalTot(:,20)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,1),zeros(nBuildings,4)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies20.txt'],buildingTechnologies,'\t');

%scenario 21
storageFactors(21,1)=0.2;
gridWeights(21,1)=0;
co2signalTot(:,21)=mean(co2_factor(1:end-1,3))*ones(35041,1); %const
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,2),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies21.txt'],buildingTechnologies,'\t');

%scenario 22
storageFactors(22,1)=0.2;
gridWeights(22,1)=0;
co2signalTot(:,22)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,2),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies22.txt'],buildingTechnologies,'\t');

%scenario 23
storageFactors(23,1)=0.2;
gridWeights(23,1)=100;
co2signalTot(:,23)=co2_factor(1:end-1,2); %marginal
buildingTechnologies=[zeros(nBuildings,1),ones(nBuildings,2),zeros(nBuildings,3)];
dlmwrite([destFolderInputOpti,'\buildingTechnologies23.txt'],buildingTechnologies,'\t');

gridWeights(gridWeights>0)=100;

co2signalTot(co2signalTot<0.01)=0.01;

%%
%save all other data sets
dlmwrite([destFolderInputOpti,'\CO2dyn.txt'],co2signalTot,'\t'); disp('done');
dlmwrite([destFolderInputOpti,'\dotQSH.txt'],dotQHeat,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\dotQDHW.txt'],dhw,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\congestionPower.txt'],p_cong_grid,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\EVcons.txt'],EVcons,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\EVavailability.txt'],ev_occ,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\storageFactors.txt'],storageFactors,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\gridWeights.txt'],gridWeights,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\buildingFeeder.txt'],buildingFeeder,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\ALC.txt'],p_alc_grid,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\ALCFeeder.txt'],p_alc_feeder,'\t');disp('done');
dlmwrite([destFolderInputOpti,'\weatherData.txt'],[(0:900:31536000)',Tamb(end-35040:end,1)],'\t');disp('done');

