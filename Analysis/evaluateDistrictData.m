function [ powerHP,powerEV,powerCHP,powerHR,powerBat,dynInputEnergy,ALCbefore,ALCafter,emissionsBefore ] = evaluateDistrictData( inputFolder,resultFolder,etaBoiler,CO2factorGas, CO2factorCar)
    dotQSH=dlmread([inputFolder,'\dotQSH.txt']);
    dotQDHW=dlmread([inputFolder,'\dotQDHW.txt']);
 

    if exist([resultFolder,'\powerHP.txt'])
        powerHP=dlmread([resultFolder,'\powerHP.txt']);
    else
        powerHP=zeros(size(dotQSH));
    end
    
    if exist([resultFolder,'\powerCHP.txt'])
        powerCHP=dlmread([resultFolder,'\powerCHP.txt']);
    else
        powerCHP=zeros(size(dotQSH));
    end
    
    if exist([resultFolder,'\powerEV.txt'])
        powerEV=dlmread([resultFolder,'\powerEV.txt']);
    else
        powerEV=zeros(size(dotQSH));
    end 
    
    if exist([resultFolder,'\powerHR.txt'])
        powerHR=dlmread([resultFolder,'\powerHR.txt']);
    else
        powerHR=zeros(size(dotQSH));
    end
    
    if exist([resultFolder,'\powerBat.txt'])
        powerBat=dlmread([resultFolder,'\powerBat.txt']);
    else
        powerBat=zeros(size(dotQSH));
    end
    powerHP=powerHP(1:end-1,:);
    powerCHP=powerCHP(1:end-1,:);
    powerEV=powerEV(1:end-1,:);
    powerHR=powerHR(1:end-1,:);
    powerBat=powerBat(1:end-1,:);
    
    try
        dynInputEnergy=dlmread([inputFolder,'\CO2dyn.txt']);
    catch
        dynInputEnergy=dlmread([inputFolder,'\PE_dyn.txt']);
    end
    dynInputEnergy=dynInputEnergy(1:35040,:);
    ALCbefore=dlmread([inputFolder,'\ALC.txt']);
    ALCafter=dlmread([resultFolder,'\loadCapacityGrid.txt']);
    if size(ALCafter,1)>size(ALCbefore,1)
        ALCafter=ALCafter(1:size(ALCbefore,1));
    end
    
    drivingDistance=dlmread([inputFolder,'\DrivingDistance.txt']);
    drivingDistance=sum(drivingDistance);

    emissionsBefore(1,:)=sum(dotQSH)/4/etaBoiler*CO2factorGas; %heating related emissions
    emissionsBefore(2,:)=sum(dotQDHW)/4/etaBoiler*CO2factorGas; %heating related emissions
    emissionsBefore(3,:)=drivingDistance*CO2factorCar; %transport related emissions
end

%%heat demand extra ausweisen (dann kann er als Referenz für die x-Achse
%%genutzt werden)
%%emissions before dann in einer extra Funktion berechnen (oder einfach so)
