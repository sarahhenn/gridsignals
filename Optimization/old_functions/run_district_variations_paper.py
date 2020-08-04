# -*- coding: utf-8 -*-
"""
Created on Sat Jul 09 18:04:59 2016

@author: ssi
"""

import run_district_func
import numpy as np


sourceFolder="D:\Ergebnisse\Optimization\InputData"
t_amb=np.loadtxt(sourceFolder+"\\Wetterdaten_IBP.txt")
t_amb=t_amb[:,2]

fpe_orig = np.loadtxt(sourceFolder+"\PE_dyn.txt")

#congestionPower=np.loadtxt(sourceFolder+"\congestionPower.txt")
congestionPower=np.zeros((35040,))
loadCapacityGrid=np.loadtxt(sourceFolder+"\ALC.txt")
loadCapacityFeeder=np.loadtxt(sourceFolder+"\ALCFeeder.txt")
buildingFeeder=np.loadtxt(sourceFolder+"\\buildingFeeder.txt")

fpe_dyn=fpe_orig
fpe_dyn[congestionPower>0]=0
#qhouse = np.loadtxt("D:\Ergebnisse\Paper_Fraunhofer\Input\dotQSH.txt")
qhouse = np.loadtxt(sourceFolder+"\q_house.txt")

qdhw=np.loadtxt(sourceFolder+"\dotQDHW.txt")

buildingTypes=np.loadtxt(sourceFolder+"\\buildingTypes.txt")
nUsers=np.loadtxt(sourceFolder+"\\nUsers.txt")

inputData = {"t_amb": t_amb, "fpe_dyn": fpe_dyn,
             "congestionPower":np.zeros(np.size(t_amb)), "qhouse":qhouse,"qdhw":qdhw,"utilLimitUpper":0.75,"utilLimitLower":0.01}
stoData={"delta_T_DHW":5,"delta_T_max":10,"storage_factor":1,"T_amb_sto":12,"k_sto":0.66,"k_sto_DHW":0.66}
HPData={"HPfactor":1.5}
configData={"daysForecast":1,"nBuildings":57,"buildingTypes":buildingTypes,"nUsers":nUsers}

stoData["storage_factor"]=1
configData["nDays"]=10
configData["nBuildings"]=34
#target_path="D:\Ergebnisse\Paper_Fraunhofer\WOCong\\"
#run_district_func.run(target_path,stoData,HPData,configData,inputData)

inputData["loadCapacityGrid"]=loadCapacityGrid
inputData["loadCapacityFeeder"]=loadCapacityFeeder
inputData["buildingFeeder"]=buildingFeeder
target_path="D:\Ergebnisse\Paper_Fraunhofer\WithCong\\"

run_district_func.run(target_path,stoData,HPData,configData,inputData)