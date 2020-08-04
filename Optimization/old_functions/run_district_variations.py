# -*- coding: utf-8 -*-
"""
Created on Sat Jul 09 18:04:59 2016

@author: ssi
"""

import run_district_func
import numpy as np

t_amb=np.loadtxt("..\Input\TRY2010_13_Jahr.dat", skiprows=38, usecols=(8,9))
t_amb=t_amb[:,0]
t_amb=np.interp(np.linspace(0,8760,35041),np.linspace(0,8760,8761),t_amb)

fpe_total   = np.loadtxt("X:\Projekte\EBC_ACS0001_Netzreaktive_Gebaeude_ssi\Project_Admin\Publications\\2016_Bewertungsverfahren_WP\InputDaten\PEFactors.txt")
fpe_dyn=fpe_total[:,4]
congestionPower=np.loadtxt("..\Input\congestionPower.txt")
qhouse = np.loadtxt("D:\Ergebnisse\Clima2016\Inputs\q_house.txt")*1000
qdhw=np.loadtxt("D:\Ergebnisse\Clima2016\Inputs\q_dhw.txt")

inputData = {"t_amb": t_amb, "fpe_dyn": np.mean(fpe_dyn)*np.ones(np.size(fpe_dyn)),"congestionPower":np.zeros(np.size(t_amb)), "qhouse":qhouse,"qdhw":qdhw}
stoData={"delta_T_DHW":2,"delta_T_max":4,"storage_factor":1,"T_amb_sto":12,"k_storage":0.3}
configData={"daysForecast":1,"nBuildings":57,"buildingTypes":2*np.ones(57,),"nUsers":4*np.ones(57,)}
inputData["qhouse"]=np.zeros((np.size(qhouse,0),np.size(qhouse,1)))
inputData["qdhw"]=qhouse+qdhw
target_path="D:\Ergebnisse\BINE\HeatDriven\\"
stoData["storage_factor"]=4
run_district_func.run(target_path,stoData,configData,inputData)
#
inputData["fpe_dyn"]=fpe_dyn
inputData["congestionPower"]=congestionPower
stoData["delta_T_DHW"]=10
stoData["delta_T_max"]=10
configData["daysForecast"]=3
target_path="D:\Ergebnisse\BINE\NormalStorage\\"
run_district_func.run(target_path,stoData,configData,inputData)

stoData["storage_factor"]=3
stoData["storage_factor"]=12
target_path="D:\Ergebnisse\BINE\BiggerStorage3\\"
run_district_func.run(target_path,stoData,configData,inputData)

stoData["storage_factor"]=5
stoData["storage_factor"]=20
target_path="D:\Ergebnisse\BINE\BiggerStorage5\\"
run_district_func.run(target_path,stoData,configData,inputData)