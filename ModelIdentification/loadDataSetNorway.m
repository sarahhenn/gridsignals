function [Ti,Ta,Papp,PhiG,Prad,Pvent] = loadDataSetNorway(folder,isMat)

volumeRooms=[24;34.69;38.81;43.51;38.54;39.7;179;77.14;18.9];
shareVolume=volumeRooms/sum(volumeRooms);
infiltRate=3;
rho_air=1.2;
C_air=1005;
if isMat==0
    rooms={'bathroom 1st floor','bathroom 2nd floor','bedroom nw','bedroom se','bedroom sw','corridor 2nd floor','kitchen & living room','stairs','technical room'};
    for k=1:length(rooms)
        test=importdata([folder,'\',rooms{k},'\TEMPERATURES.prn']);
        TiTot(:,k)=test.data(:,3);
%         disp(k);
    end
    timeSim=test.data(:,1);
    Ti=TiTot*shareVolume; %calculate volume weighted indoor air temperature
    Ti = extractDataConstantTimeSteps( timeSim,Ti,300 ); %get the dataset in 5 minute steps
    weather=importdata([folder,'\OSLO2016.prn']);
    timeWeather=weather.data(:,1);
    Ta=weather.data(:,2);
    Ta = extractDataConstantTimeSteps( timeWeather,Ta,300 ); %get the dataset in 5 minute steps
    PhiG=weather.data(:,6);
    PhiG = extractDataConstantTimeSteps( timeWeather,PhiG,300 ); %get the dataset in 5 minute steps
    
    energyData=importdata([folder,'\SUPPLIED-ENERGY.prn']);
    timeEnergyData=energyData.data(:,1);
    Prad=energyData.data(:,3);
    Prad = extractDataConstantTimeSteps( timeEnergyData,Prad,300 ); %get the dataset in 5 minute steps
    Papp=energyData.data(:,4)+energyData.data(:,6);
    Papp = extractDataConstantTimeSteps( timeEnergyData,Papp,300 ); %get the dataset in 5 minute steps

    Pvent=infiltRate*sum(volumeRooms)/3600*rho_air*C_air*(Ta-Ti);
end
end

