%%
%read simulation data France (1982)
[Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT1982_EPLUS_PRBS.csv', 1, 105120);
[TiVal,PradVal,PhiGVal,TaVal,PappVal,n_air,n_inf,PventVal] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT1982_EPLUS_Constant.csv', 1, 105120);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(1500:50000);

%%
%read simulation data France (2005)
[Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT2005_EPLUS_PRBS.csv', 1, 105120);
[TiVal,PradVal,PhiGVal,TaVal,PappVal,n_air,n_inf,PventVal] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT2005_EPLUS_Constant.csv', 1, 105120);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(1500:50000);

%%
%read simulation data France (2020)
[Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT2020_EPLUS_PRBS.csv', 1, 105120);
[TiVal,PradVal,PhiGVal,TaVal,PappVal,n_air,n_inf,PventVal] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\France\results_SFH_RT2020_EPLUS_Constant.csv', 1, 105120);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(1500:end);

%%
%read simulation data Denmark (1980)
[Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Denmark\results_SFH_DK_1980_EPLUS_PRBS.csv', 1, 105120);
[TiVal,PradVal,PhiGVal,TaVal,PappVal,n_air,n_inf,PventVal] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Denmark\results_SFH_DK_1980_EPLUS_Constant.csv', 1, 105120);
COP=0.35*(273.15+45)*(45-Ta).^(-1);
Prad=Prad.*COP;
PradVal=PradVal.*COP;
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(17000:40000);
dataRed=dataOrig(1500:end);

subplot(2,1,1);
plot(Ti(1500:6000));
subplot(2,1,2);
plot(Prad(1500:6000));

%%
%read simulation data Denmark (PH)
[Ti,Prad,PhiG,Ta,Papp,n_air,n_inf,Pvent] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Denmark\results_SFH_DK_PH_EPLUS_PRBS.csv', 1, 105120);
[TiVal,PradVal,PhiGVal,TaVal,PappVal,n_air,n_inf,PventVal] = loadDataSetDenmarkFrance('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Denmark\results_SFH_DK_PH_EPLUS_Constant.csv', 1, 105120);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(1500:6000);
%%
%read simulation data Germany
[Ti,Ta,Papp,PhiG,Prad,Pvent] = readModelOutputsDymola('D:\Ergebnisse\Test_einzelsimulationen\OFD_1Jan_HighPower.mat');
[TiVal,TaVal,PappVal,PhiGVal,PradVal,PventVal] = readModelOutputsDymola('D:\Ergebnisse\Test_einzelsimulationen\OFD_1Jan.mat');
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=dataOrig(1500:6120);

%%
%read simulation data  (light)
[Ti,Ta,Papp,PhiG,Prad,Pvent] = loadDataSetNorway('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Norway\2018_06_06_TABULACM5_Ref_NS',0);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataRed=dataOrig(17000:40000);

%%
%read simulation data Norway (heavy)
[Ti,Ta,Papp,PhiG,Prad,Pvent] = loadDataSetNorway('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Norway\HCM\2018_06_06_TABULACM1_Ref_NS',0);
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataRed=dataOrig(17000:40000);

%%
%read simulation data Spain (cooling)
[Ta,Ti,PhiG,Prad,Pvent,Papp] = loadDataSetSpain('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Spain\data_RC_model_COOLING.XLSX');
[TaVal,TiVal,PhiGVal,PradVal,PventVal,PappVal] = importResultsSpain('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Spain\data_RC_model_HEATING.XLSX');
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=[dataOrig;dataValidate];
%%
%read simulation data Spain (heating)
[Ta,Ti,PhiG,Prad,Pvent,Papp] = loadDataSetSpain('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Spain\data_RC_model_HEATING.XLSX');
[TaVal,TiVal,PhiGVal,PradVal,PventVal,PappVal] = importResultsSpain('D:\MeineDaten\Stipendium\PaperAnnex\Datasets\Spain\data_RC_model_COOLING.XLSX');
dataOrig=iddata(Ti,[Ta,PhiG,Papp,Prad,Pvent],300);
dataValidate=iddata(TiVal,[TaVal,PhiGVal,PappVal,PradVal,PventVal],300);
dataRed=[dataOrig;dataValidate];

%%
%model identification (for R2C2 model)
% Define initial parameter vectors
clear R2C2_model
par_R2C2 = [0.1 0.1 0.4 12 2];                                 % [UAia;UAea;Ci;Ce;G]

opt_GB    = greyestOptions('InitialState','estimate',...
    'DisturbanceModel','none',...
    'EstCovar',true,...
    'SearchMethod','gn',...
    'Focus','Simulation'...
    );

%Identify models with global solar radiation
R2C2_model= idgrey('R2C2',par_R2C2,'c');
R2C2_model.Structure.Parameters.Minimum = [0 0 0 0 0];
R2C2_model.Structure.Parameters.Maximum = [inf inf inf inf inf];
R2C2_model.Structure.Parameters.Maximum = [inf inf 0.3 inf inf]; %it might sometimes be necessary to restrict the parameter for the inner capacity (basically air capacity)

R2C2_model= greyest(dataRed, R2C2_model, opt_GB);
disp('Model identification finished!')


%%
%comparison of the identified model with the original data set
simOpt = simOptions('InitialCondition',[dataValidate.y(1);dataValidate.y(1)]);
[y,z]=compare(dataOrig,sim(R2C2_model,dataOrig,simOpt));
Ti_model=y.y;
h1=figure;
subplot(2,1,1);
set(gca,'FontSize',20);
plot(Ti);
hold on
plot(Ti_model);
legend('detailed','R2C2');
ylabel('Temperature in °C','FontSize',18);

subplot(2,1,2);
plot(Ti_model-Ti);
ylabel('Temperature difference in K','FontSize',18);
%%
%comparison of the identified model with a potential validation data set
simOpt = simOptions('InitialCondition',[dataValidate.y(1);dataValidate.y(1)]);
[y,z]=compare(dataValidate,sim(R2C2_model,dataValidate,simOpt));
Ti_model=y.y;
h1=figure;
subplot(2,1,1);
plot(TiVal);
hold on
plot(Ti_model);
legend('detailed','R2C2');
ylabel('Temperature in °C','FontSize',18);
subplot(2,1,2);
plot(Ti_model-TiVal);
ylabel('Temperature difference in K','FontSize',18);