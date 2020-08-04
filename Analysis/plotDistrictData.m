function [ done ] = plotDistrictData( powerHP,powerEV,dynInputEnergy,ALCbefore,ALCafter,startDate,endDate )

    h1=figure;
    subplot(3,1,1);
    plot(dynInputEnergy((startDate-1)*96+1:endDate*96));
    subplot(3,1,2);
    plot(sum(powerHP((startDate-1)*96+1:endDate*96,:),2),'r');
    hold on;
    plot(sum(powerEV((startDate-1)*96+1:endDate*96,:),2),'b');
    legend('HP','EV');
    subplot(3,1,3);
    plot(ALCbefore((startDate-1)*96+1:endDate*96),'b');
    hold on;
    plot(ALCafter((startDate-1)*96+1:endDate*96),'r');
    legend('before','after');
    done=1;

end

