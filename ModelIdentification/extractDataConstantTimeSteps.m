function [ dataSetOut ] = extractDataConstantTimeSteps( timeVec,dataSet,timeStep )
%Resample and calculate minutely average for each parameter (per column) from imported files
%   Result prn-files are imported and the minutely average values for each of the parameters is calculated

%% Resample and calculate hourly average for each parameter (per column)

%     D = importdata(filename);
%     FileD = D.data;
%     Data = FileD(:,:);               %read all columns from the matrix
% 
%     timesD = D.data(:,[1]);                     %has the original time step from IDA IDE
%     tsD = timeseries(Data,timesD);

    newTimes = [0:timeStep/3600:8760]';           %has hourly time step

%     fullMinutes=find(mod(timeVec,1)==0);     % "mod" gibt den Rest an, wenn ich den Wert in the Zelle mit 1 teile und gibt die Werte aus, die einen Rest 0 haben, weil das bei ejder vollen Stunde der Fall ist
    doubleIdx=find(diff(timeVec)==0);     % finds the full hours with a difference of 1 hour 

    % Creating a new data matrix which does not include the hours twice anymore
    dataSetNew=dataSet;
    dataSetNew(doubleIdx+1)=[];
    timeVecNew=timeVec;
    timeVecNew(doubleIdx+1)=[];
    
    dataSetOut=interp1(timeVecNew,dataSetNew,newTimes);


end

