function [Ti,Ta,Papp,PhiG,Prad,Pvent] = readModelOutputsDymola(fileName)
    
    data = dymload(fileName);
    Ti=dymget(data,'TAirRoomsAvg');
    Ta=dymget(data,'Toutside');
    Papp=dymget(data,'Papp');
    PhiG=dymget(data,'PhiG');
    Prad=dymget(data,'PHeatTot');
    Pvent=dymget(data,'VentilationLossesTot');
    %set up data
    if length(Papp)==2
        Papp=Papp(1)*ones(size(Ta));
    end


end

