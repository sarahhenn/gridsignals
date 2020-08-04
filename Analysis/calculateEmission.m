function [emissionChange,emissionChangeCong] = calculateEmission(powerHP,powerEV,powerCHP,powerDHW,powerBat,etaCHPel,dynInputEnergy,emissionsBuildBefore,orderBuild,CO2gas,CO2cong,ALCbefore)
    nBuildings=size(powerHP,2);
    ALCact=ALCbefore;
    for k=1:length(orderBuild)
        
        emissionChange(k)=sum(powerBat(:,orderBuild(k)).*dynInputEnergy)/4 ...
            +sum(powerDHW(:,orderBuild(k)).*dynInputEnergy)/4 ...
            +sum(powerHP(:,orderBuild(k)).*dynInputEnergy)/4 ...
            +sum(powerCHP(:,orderBuild(k))/etaCHPel)*CO2gas/4-sum(powerCHP(:,orderBuild(k)).*dynInputEnergy)/4 ...
            +sum(powerEV(:,orderBuild(k)).*dynInputEnergy)/4;
        
        
        if sum(powerHP(:,orderBuild(k))>0)>0 || sum(powerCHP(:,orderBuild(k))>0)>0
            emissionChange(k)=emissionChange(k)-emissionsBuildBefore(1,k)-emissionsBuildBefore(2,k);
        else           
            if sum(sum(powerDHW))>0
                emissionChange(k)=emissionChange(k)-emissionsBuildBefore(2,k);
            end
        end
            
          
        if sum(powerEV(:,orderBuild(k))>0)>0 %if an EV replaces the conventional car, the conventional emissions need to be subtracted
            emissionChange(k)=emissionChange(k)-emissionsBuildBefore(3,k);
        end
        
        %add share of reduced congestions to emission change
        %
        congInjDynBefore=(ALCact>0.8).*(ALCact-0.8);
        ALCact=ALCbefore-sum(powerHP(:,orderBuild(1:k)),2)/1000-sum(powerEV(:,orderBuild(1:k)),2)/1000+sum(powerCHP(:,orderBuild(1:k)),2)/1000-sum(powerDHW(:,orderBuild(1:k)),2)/1000-sum(powerBat(:,orderBuild(1:k)),2)/1000;
        congInjDynAfter=(ALCact>0.8).*(ALCact-0.8);
        emissionChangeCong(k)=sum(min(congInjDynAfter-congInjDynBefore,0).*max(dynInputEnergy-CO2cong,0))*1000/4;
        emissionChange(k)=emissionChange(k)+emissionChangeCong(k);        
    end
    

end