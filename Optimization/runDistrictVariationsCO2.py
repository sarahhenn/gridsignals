# -*- coding: utf-8 -*-
"""
Created on Sat Jul 09 18:04:59 2016

@author: ssi
"""

import runDistrictFuncCO2AllTech
import numpy as np

#determine the optimization folder in which all input data and results are placed
operationFolder="D:\Ergebnisse\Optimization_Evaluation_2030_ELEC_MV"
#the input data is always in this source folder
sourceFolder=operationFolder+"\\InputData"


#load all necessary data sets
weatherData=np.loadtxt(sourceFolder+"\\weatherData.txt")
t_amb=weatherData[:,1]

co2_dyn=np.loadtxt(sourceFolder+"\CO2dyn.txt")
congestionPower=np.loadtxt(sourceFolder+"\congestionPower.txt")

loadCapacityGrid=np.loadtxt(sourceFolder+"\ALC.txt")
loadCapacityFeeder=np.loadtxt(sourceFolder+"\ALCFeeder.txt")
buildingFeeder=np.loadtxt(sourceFolder+"\\buildingFeeder.txt")

#for CO2 scenarios, the co2 factor will be set to the lowest value in case congestions because of renewables occur
print("Change the number of scenarios")
for k in range(0,np.size(co2_dyn,1)):
    if co2_dyn[:,k].max()>1.1*co2_dyn[:,k].mean():
        print("CO2 signal "+str(k)+" was changed!")
        
        co2_dyn[congestionPower>0,k]=co2_dyn.min()

qhouse = np.loadtxt(sourceFolder+"\dotQSH.txt")

qdhw=np.loadtxt(sourceFolder+"\dotQDHW.txt")

#load data for EV operation
EVavailability=np.loadtxt(sourceFolder+"\\EVavailability.txt")
EVcons=np.loadtxt(sourceFolder+"\\EVcons.txt")

#generate different dictionaries for the different input data sets to cluster them and make them easier accessible for other functions
inputData = {"t_amb": t_amb, "congestionPower":np.zeros(np.size(t_amb)), "qhouse":qhouse,"qdhw":qdhw,"utilLimitUpper":0.75,"utilLimitLower":0.1,
            "utilLimitUpperFeeder":0.16,"utilLimitLowerFeeder":0.02,"elDemEV":EVcons,"EVavailability":EVavailability}
stoData={"storage_factor":1,"T_amb_sto":12,"k_sto":0.66,"k_sto_DHW":0.66}
HPData={"HPfactor":1.0}
EVData={"Pmin":0,"Pmax":11,"SOCmin":0.1,"SOCmax":0.95,"energyContent":35,"etaCh":0.91,"etaDis":0.91,"selfDis":1e-4,"withFeedIn":1}
batData={"Pmin":0,"Pmax":11,"SOCmin":0.1,"SOCmax":0.95,"energyContent":35,"etaCh":0.91,"etaDis":0.91,"selfDis":1e-4}



print("Co2 factor needs to be changed!!!")
inputData["CO2gas"]=1.1

inputData["loadCapacityGrid"]=loadCapacityGrid
inputData["loadCapacityFeeder"]=loadCapacityFeeder
inputData["buildingFeeder"]=buildingFeeder
parallelData={"runParallel":0}

#Set up data sets that might be changed
storageFactors=np.loadtxt(sourceFolder+"\storageFactors.txt")
gridWeights=np.loadtxt(sourceFolder+"\gridWeights.txt")

#run optimization for dedicated types of systems
for k in range(1,6):       
    #reading the actual building technology distribution    
    buildingTypes=np.loadtxt(sourceFolder+"\\buildingTechnologies"+str(k)+".txt")
    #using the actual storage factor and the dynamic co2 factor
    stoData["storage_factor"]=storageFactors[k-1]
    inputData["co2_dyn"]=co2_dyn[:,k-1]
    configData={"daysForecast":2,"startBuilding":1,"endBuilding":180,"startDay":1,"endDay":365,"buildingTypes":buildingTypes}
    configData["BESdata"]=1
    configData["extraDHW"]=1
    configData["withEV"]=1
    configData["weightGrid"]=gridWeights[k-1]

    target_path=operationFolder+"\\"+str(k)+"\\"

    runDistrictFuncCO2AllTech.run(target_path,stoData,HPData,EVData,batData,configData,inputData,parallelData)
    
for k in range(14,16):       
    buildingTypes=np.loadtxt(sourceFolder+"\\buildingTechnologies"+str(k)+".txt")
    stoData["storage_factor"]=storageFactors[k-1]
    inputData["co2_dyn"]=co2_dyn[:,k-1]
    configData={"daysForecast":2,"startBuilding":1,"endBuilding":180,"startDay":1,"endDay":365,"buildingTypes":buildingTypes}
    configData["BESdata"]=1
    configData["extraDHW"]=1
    configData["withEV"]=1
    configData["weightGrid"]=gridWeights[k-1]

    target_path=operationFolder+"\\"+str(k)+"\\"

    runDistrictFuncCO2AllTech.run(target_path,stoData,HPData,EVData,batData,configData,inputData,parallelData)    