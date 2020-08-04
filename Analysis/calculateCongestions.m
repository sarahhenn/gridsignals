function [congLoad,congInj] = calculateCongestions(ALCbefore,powerHP,powerEV,powerCHP,powerDHW,powerBat,orderBuild)

    for k=1:length(orderBuild)
        ALCact=ALCbefore-sum(powerHP(:,orderBuild(1:k)),2)/1000-sum(powerEV(:,orderBuild(1:k)),2)/1000+sum(powerCHP(:,orderBuild(1:k)),2)/1000-sum(powerDHW(:,orderBuild(1:k)),2)/1000-sum(powerBat(:,orderBuild(1:k)),2)/1000;
        congLoad(k)=sum((ALCact<0).*(0-ALCact))/4;
        congInj(k)=sum((ALCact>0.8).*(ALCact-0.8))/4;
    end
end

