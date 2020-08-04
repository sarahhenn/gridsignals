# -*- coding: utf-8 -*-
"""
Created on Thu Apr 07 15:35:38 2016

@author: tsz,ssi
"""
from __future__ import division

import optimizationModelCO2HP as optiHP
import optimizationModelCO2CHP as optiCHP
import optimizationModelCO2EV as optiEV
import optimizationModelCO2Battery as optiBat
import optimizationModelCO2EHDHW as optiEHDHW


import numpy as np
import time
import Definition_COP_Pmax as defCOP
import BESdataGeneral as BESdata

def run(target_path,stoData,HPData,EVData,batData,configData,inputData,parallelData):
        #timer for the whole simulation process is started
        t=time.time()
        
        #extract some data sets from the dictionaries (only necessary for parallel simulation)
        buildingTypes=configData["buildingTypes"]
        startBuilding=configData["startBuilding"]     
        endBuilding=configData["endBuilding"]
        startDay=configData["startDay"]     
        endDay=configData["endDay"]
        weightGrid=configData["weightGrid"]
        daysForecast=configData["daysForecast"]  
        nDays=endDay-startDay+1
        # Load weather data
        t_amb=inputData["t_amb"]
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)
        t_amb = np.concatenate((t_amb,t_amb[1:(daysForecast*96)+1]))
        
        #Define storage data   
        rho = 1000 # kg/m3
        cp = 4.180 # kJ/kgK
        conv_kJ_2_kWh = 1 / 3600
        
        stoData["rho"]=rho
        stoData["cp"]=cp
        stoData["conv_kJ_2_kWh"]=conv_kJ_2_kWh

        if parallelData["runParallel"]==1:       
            storage_factor=parallelData["storageFactor"]      
            stoData["storageFactor"]=storage_factor
        else:               
            storage_factor=stoData["storage_factor"]

        T_amb_sto=stoData["T_amb_sto"]
        k_sto=stoData["k_sto"]
        
        HPfactor=HPData["HPfactor"]    

        #load space heating demand
        heatDemWhole = inputData["qhouse"]
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)
        heatDemWhole = np.concatenate((heatDemWhole,heatDemWhole[97:(daysForecast*96)+97,:]))
       
        #load dhw heat demand
        heatDHWWhole=inputData["qdhw"]  
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)        
        heatDHWWhole = np.concatenate((heatDHWWhole,heatDHWWhole[97:(daysForecast*96)+97,:]))
        
        #read EV data sets        
        if configData["withEV"]: #if EV data sets are relevant
            elDemWhole=inputData["elDemEV"]
            #attach the first day(s) at the end of the data set to be able to perform an optimization 
            #for the last day with forecast for the following day(s)
            elDemWhole = np.concatenate((elDemWhole,elDemWhole[97:(daysForecast*96)+97,:]))
            inputData["elDemEV"]=elDemWhole
            EVavailabilityWhole=inputData["EVavailability"]
            #attach the first day(s) at the end of the data set to be able to perform an optimization 
            #for the last day with forecast for the following day(s)            
            EVavailabilityWhole = np.concatenate((EVavailabilityWhole,EVavailabilityWhole[97:(daysForecast*96)+97,:]))
            inputData["EVavailability"]=EVavailabilityWhole
            
        # load CO2 inputs
        if parallelData["runParallel"]==1:
            co2_dyn=parallelData["co2_dyn"]
        else:
            co2_dyn=inputData["co2_dyn"]           
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)
        co2_dyn = np.concatenate((co2_dyn,co2_dyn[1:(daysForecast*96)+1]))

        #read data sets for the grid        
        if parallelData["runParallel"]==1:
            loadCapacityGrid=parallelData["loadCapacityGrid"]
        else:
            loadCapacityGrid=inputData["loadCapacityGrid"]
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)        
        loadCapacityGrid= np.concatenate((loadCapacityGrid,loadCapacityGrid[1:(daysForecast*96)+1]))
        loadCapacityFeeder=inputData["loadCapacityFeeder"]
        #attach the first day(s) at the end of the data set to be able to perform an optimization 
        #for the last day with forecast for the following day(s)        
        loadCapacityFeeder= np.concatenate((loadCapacityFeeder,loadCapacityFeeder[1:(daysForecast*96)+1,:]))
        utilLimitUpper=inputData["utilLimitUpper"]        
        utilLimitLower=inputData["utilLimitLower"]
        utilLimitLowerFeeder=inputData["utilLimitLowerFeeder"] 
        utilLimitUpperFeeder=inputData["utilLimitUpperFeeder"] 
        buildingFeeder=inputData["buildingFeeder"]    
        
        misc = {"dt" : 0.25, # quarter hourly sampling
        "time steps" : (daysForecast+1)*96,"CO2gas":inputData["CO2gas"]}        

        #initialize the power arrays for all technologies
        powerHP=np.zeros((35041,endBuilding))
        heatHP=np.zeros((35041,endBuilding))
        TStoHP=np.zeros((35041,endBuilding))
        powerCHP=np.zeros((35041,endBuilding))
        gasCHP=np.zeros((35041,endBuilding))
        powerEV=np.zeros((35041,endBuilding))
        powerBat=np.zeros((35041,endBuilding))
        powerDHW=np.zeros((35041,endBuilding))
        penaltySignal=np.zeros((35041,endBuilding))
        SOCtot=np.zeros((35041,endBuilding))
        
        #calculating random sequence of buildings, but initializing it with a certain RandomState
        #with this approach, we can assure that the same sampling is used whenever a district with the same amount of buildings is calculated
        prng = np.random.RandomState(500000)       
        newBuildingOrder=prng.permutation(endBuilding)
        
        for houseCounter in range(startBuilding-1,endBuilding):       
            nHouse=newBuildingOrder[houseCounter] #taking the house number from the new (randomized) building order
            if (buildingTypes[nHouse,0]==1)|(buildingTypes[nHouse,1]==1)|(buildingTypes[nHouse,4]==1): #electric heating system is involved
                configData["actHouse"]=nHouse
                if buildingTypes[nHouse,4]==1: #DHW production with direct electric heating
                    #heat demand for the single building (only space heating)
                    heatDem=heatDemWhole[:,nHouse]
                    totalSH=np.sum(heatDem)/4
                    #extra calculation for DHW
                    heatDemDHW=heatDHWWhole[:,nHouse]                    
                    totalDHW=np.sum(heatDemDHW)/4
                    maxDem=np.max(heatDem)
                    maxDemDHW=np.max(heatDHWWhole[:,nHouse])
                    #BES size calculation
                    if (buildingTypes[nHouse,0]==1): #HP for space heating
                        (heating_curve,sto_vol,A_sto,deltaTmax,conv_kWh_2_K)=BESdata.defineBESData("HP",stoData,t_amb,totalSH,storage_factor)
                    elif (buildingTypes[nHouse,1]==1): #CHP for space heating
                        (heating_curve,sto_vol,A_sto,deltaTmax,conv_kWh_2_K)=BESdata.defineBESData("CHP",stoData,t_amb,totalSH,storage_factor)
                    (heating_curveDHW,sto_volDHW,A_stoDHW,deltaTmaxDHW,conv_kWh_2_KDHW)=BESdata.defineBESData("EHDHW",stoData,t_amb,totalDHW,storage_factor)                    
                    #initialize storage temperature for DHW storage for the first day
                    old_T_stoDHW=heating_curveDHW[0]+deltaTmaxDHW/2 

                else:
                    #heat demand for the single building (space heating + DHW)
                    heatDem=heatDemWhole[:,nHouse]+heatDHWWhole[:,nHouse]
                    totalSH=np.sum(heatDem)/4
                    maxDem=np.max(heatDemWhole[:,nHouse])
                    if (buildingTypes[nHouse,0]==1): #HP for space heating and DHW
                        (heating_curve,sto_vol,A_sto,deltaTmax,conv_kWh_2_K)=BESdata.defineBESData("HP",stoData,t_amb,totalSH,storage_factor)
                    elif (buildingTypes[nHouse,1]==1): #CHP for space heating and DHW
                        (heating_curve,sto_vol,A_sto,deltaTmax,conv_kWh_2_K)=BESdata.defineBESData("CHP",stoData,t_amb,totalSH,storage_factor)                    
                
                #initialize storage temperature for SH storage for the first day (in case no direct electric DHW is used, it is also the DHW storage)
                old_T_sto=heating_curve[0]+deltaTmax/2
            
            if (buildingTypes[nHouse,2]==1): #EV is involved
                #initialize EV SOC for the first day                    
                SOColdEV=0.5  
            if (buildingTypes[nHouse,3]==1): #Battery is involved
                #initialize battery SOC for the first day
                SOColdBat=0.5  
                  
            #initialize all output variables
            heat_total=np.zeros(35041,)
            T_sto_total=np.zeros(35041,)
            T_sto_totalDHW=np.zeros(35041,)
            
            objValTotal=np.zeros(nDays,)
            MIPGapTotal=np.zeros(nDays,)
            RuntimeTotal=np.zeros(nDays,)
            ObjBoundTotal=np.zeros(nDays,)
            
            #Here, the actual optimization starts
            for k in range(startDay-1,endDay):
                #Print statement to be clear at which point of the optimization you are at the moment 
                #(both the house number and the number of houses that are already calculated are shown)
                print("This is house " +str(nHouse+1)+"("+str(houseCounter+1)+")"+" and day " + str(k+1))

                #calculate the CO2 signal and the congestion/penalty signal                       
                (co2_total,congSignal)=calculateInteractionSignals(loadCapacityGrid,loadCapacityFeeder,utilLimitUpper,
                                utilLimitLower,utilLimitUpperFeeder,utilLimitLowerFeeder,buildingFeeder,co2_dyn,k,daysForecast,nHouse,weightGrid) 
                
                #extract only the actual day of the congestion signal for the penalty signal that can be saved later                
                penaltySignal[k*96:(k+1)*96,nHouse]=congSignal[0:96]                    

                #Set the dictionayr for HP and CHP storage data sets                
                if (buildingTypes[nHouse,0]==1)|(buildingTypes[nHouse,1]==1): #data that holds for both HP and CHP
                    sto = {"T_min": heating_curve[(k)*96:(k+daysForecast+1)*96], "T_max": heating_curve[(k)*96:(k+daysForecast+1)*96]+deltaTmax, 
                        "init": old_T_sto,"k_sto": k_sto, "A_sto": A_sto,"T_amb_sto": T_amb_sto,"conv_kWh_2_K": conv_kWh_2_K}                
                                    # load house data
                    hou = {"heat": heatDem[(k)*96:(k+daysForecast+1)*96], "congSignal":congSignal} # in kW instead of W                              
                
                if (buildingTypes[nHouse,0]==1): #HP system is investigated
                    
                    print("HP is calculated!")
                    #calculate actual cop and p_el for the HP system with a medium sink temperature                    
                    (cop,p_el)=BESdata.efficiencyRelationsHP(HPfactor,t_amb[(k)*96:(k+daysForecast+1)*96],
                             heating_curve[(k)*96:(k+daysForecast+1)*96],deltaTmax,maxDem,daysForecast)
                    print("Actual storage temperature is " +str(old_T_sto))
                    #calculate the cop and p_el if the maximum useful sink temperature is used
                    (copMin,p_elMax)=BESdata.efficiencyRelationsHP(HPfactor,t_amb[(k)*96:(k+daysForecast+1)*96],
                             heating_curve[(k)*96:(k+daysForecast+1)*96]+sto["T_max"]-sto["T_min"],deltaTmax,maxDem,daysForecast)
                    #calculate a (linearized) correction factor from the two calculations                    
                    corrFactor=(p_elMax-p_el)/(sto["T_max"]-sto["T_min"])
                    hp = {"cop": cop,"corrFactor":corrFactor, "P_min": np.zeros(np.size(p_el)),"P_max": p_el}

                    #THIS is the actual optimization where the optimization model is called                    
                    res_dyn = optiHP.optimize(hp, sto, hou, co2_total, misc)
                    #extraction of all relevant result data sets                   
                    (x_dyn, heat_dyn, power_dyn_HP, power_dyn_HR, T_sto, objVal,MIPGap,Runtime,ObjBound) = res_dyn
                    
                    #extraction of only the actual day as result (since the rest is not used because of the rolling horizon)
                    heat_total[k*96:(k+1)*96]=heat_dyn[0:96]
                    heatHP[k*96:(k+1)*96,nHouse]=heat_dyn[0:96]
                    T_sto_total[k*96:(k+1)*96]=T_sto[0:96]
                    TStoHP[k*96:(k+1)*96,nHouse]=T_sto[0:96]
                    #one last correction of COP and p_el according to the really existing storage temperature
                    (copCorr,p_elCorr)=BESdata.efficiencyRelationsHP(HPfactor,t_amb[(k)*96:(k+daysForecast+1)*96],
                             T_sto,10,maxDem,daysForecast)
                    #calculation of the actual power of the HP with the corrected COP       
                    powerHP[k*96:(k+1)*96,nHouse]=heat_dyn[0:96]/copCorr[0:96]
                    #extracting the powerDHW (which is indeed a power of a HR)
                    powerDHW[k*96:(k+1)*96,nHouse]=powerDHW[k*96:(k+1)*96,nHouse]+power_dyn_HR[0:96]
                    #setting the initial storage temperature for the next day to the final storage temperature of the actual day                    
                    old_T_sto=T_sto[95]
                    
                    #save some optimization variables
                    print(np.size(objVal))
                    objValTotal[k-(startDay-1)]=objVal
                    MIPGapTotal[k-(startDay-1)]=MIPGap
                    RuntimeTotal[k-(startDay-1)]=Runtime
                    ObjBoundTotal[k-(startDay-1)]=ObjBound

                    #update grid capacities for both the feeder and the total grid
                    loadCapacityGrid[k*96:(k+1)*96]=loadCapacityGrid[k*96:(k+1)*96]-powerHP[k*96:(k+1)*96,nHouse]/1000-power_dyn_HR[0:96]/1000
                    loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]-powerHP[k*96:(k+1)*96,nHouse]/1000-power_dyn_HR[0:96]/1000
                    if max(abs(loadCapacityFeeder[:,0]))>1:
                        print("error feeder!")
                        
                if (buildingTypes[nHouse,1]==1): #CHP system is investigated
                    print("CHP is calculated!")
                    #extract the actual CHP efficiency relations                      
                    (etael,etath,etaBoi,Pmax)=BESdata.efficiencyRelationsCHP(HPfactor,maxDem)          
                    #set all relevant data sets for CHP systems
                    chp = {"etael": etael, "etath":etath,"etaBoi":etaBoi, "P_min": 0,"P_max": Pmax}

                    #HERE. the actual optimization of the CHP system takes place where the MILP is called                     
                    res_dyn = optiCHP.optimize(chp, sto, hou, co2_total, misc)  
                    
                    #all relevant data sets are extracted
                    (x_dyn, heat_dyn, power_dyn, gas_dyn,T_sto, objVal,MIPGap,Runtime,ObjBound) = res_dyn
                    
                    #only the data sets of the respective days are further used
                    powerCHP[k*96:(k+1)*96,nHouse]=power_dyn[0:96]
                    heat_total[k*96:(k+1)*96]=heat_dyn[0:96]
                    T_sto_total[k*96:(k+1)*96]=T_sto[0:96]
                    gasCHP[k*96:(k+1)*96,nHouse]=gas_dyn[0:96]
                    #setting the initial storage temperature for the next day to the final storage temperature of the actual day                    
                    old_T_sto=T_sto[95]

                    #save some optimization variables
                    print(np.size(objVal))
                    objValTotal[k-(startDay-1)]=objVal
                    MIPGapTotal[k-(startDay-1)]=MIPGap
                    RuntimeTotal[k-(startDay-1)]=Runtime
                    ObjBoundTotal[k-(startDay-1)]=ObjBound
                
                    #update grid capacities for both the feeder and the total grid
                    loadCapacityGrid[k*96:(k+1)*96]=loadCapacityGrid[k*96:(k+1)*96]+powerCHP[k*96:(k+1)*96,nHouse]/1000
                    loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]+powerCHP[k*96:(k+1)*96,nHouse]/1000
    
                if (buildingTypes[nHouse,2]==1): #EV is involved
                    print("EV is calculated!")
                    
                    #calculate the co2 and grid penalty signals                   
                    (co2_total,congSignal)=calculateInteractionSignals(loadCapacityGrid,loadCapacityFeeder,utilLimitUpper,
                                utilLimitLower,utilLimitUpperFeeder,utilLimitLowerFeeder,buildingFeeder,co2_dyn,k,daysForecast,nHouse,weightGrid)                
                    
                    #set up all dictionaries with the relevant data for EV
                    hou={"EVcons":inputData["elDemEV"][(k)*96:(k+daysForecast+1)*96,nHouse],"congSignal":congSignal,"availability":inputData["EVavailability"][(k)*96:(k+daysForecast+1)*96,nHouse]}
                    ev=EVData
                    ev["init"]=SOColdEV
                    
                    #HERE. the actual optimization of the EV system takes place where the MILP is called 
                    res_dyn = optiEV.optimize(ev, hou, co2_total, misc)  
                    #all relevant data sets are extracted
                    (x_dyn, power_dyn, SOC, objVal,MIPGap,Runtime,ObjBound) = res_dyn

                    #only the data sets of the respective days are further used
                    powerEV[k*96:(k+1)*96,nHouse]=power_dyn[0:96]                    
                    SOCtot[k*96:(k+1)*96,nHouse]=SOC[0:96]

                    #setting the initial SOC for the next day to the final SOC of the actual day                    
                    SOColdEV=SOC[95]

                    #update grid capacities for both the feeder and the total grid
                    loadCapacityGrid[k*96:(k+1)*96]=loadCapacityGrid[k*96:(k+1)*96]-powerEV[k*96:(k+1)*96,nHouse]/1000
                    loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]-powerEV[k*96:(k+1)*96,nHouse]/1000    

                if (buildingTypes[nHouse,3]==1): #Battery is involved
                    print("Battery is calculated!")

                    #calculate the co2 and grid penalty signals                   
                    (co2_total,congSignal)=calculateInteractionSignals(loadCapacityGrid,loadCapacityFeeder,utilLimitUpper,
                                utilLimitLower,utilLimitUpperFeeder,utilLimitLowerFeeder,buildingFeeder,co2_dyn,k,daysForecast,nHouse,weightGrid)                

                    #set up all dictionaries with the relevant data for battery                 
                    hou={"congSignal":congSignal}
                    batDataTot=batData
                    batDataTot["init"]=SOColdBat
                    
                    #HERE. the actual optimization of the battery system takes place where the MILP is called                     
                    res_dyn = optiBat.optimize(batDataTot, hou, co2_total, misc) 
                    #all relevant data sets are extracted                    
                    (x_dyn, power_dyn, SOC, objVal,MIPGap,Runtime,ObjBound) = res_dyn

                    #only the data sets of the respective days are further used
                    powerBat[k*96:(k+1)*96,nHouse]=power_dyn[0:96]                    
                    SOCtot[k*96:(k+1)*96,nHouse]=SOC[0:96]
                    #setting the initial SOC for the next day to the final SOC of the actual day                    
                    SOColdBat=SOC[95]                    

                    #update grid capacities for both the feeder and the total grid
                    loadCapacityGrid[k*96:(k+1)*96]=loadCapacityGrid[k*96:(k+1)*96]-powerBat[k*96:(k+1)*96,nHouse]/1000
                    loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]-powerBat[k*96:(k+1)*96,nHouse]/1000    

                if (buildingTypes[nHouse,4]==1):  #direct electrical heating for DHW is investigated
                    print("DEH DHW is calculated!")
                    #calculate the co2 and grid penalty signals                   
                    (co2_total,congSignal)=calculateInteractionSignals(loadCapacityGrid,loadCapacityFeeder,utilLimitUpper,
                                utilLimitLower,utilLimitUpperFeeder,utilLimitLowerFeeder,buildingFeeder,co2_dyn,k,daysForecast,nHouse,weightGrid)                
                                
                    #set up all dictionaries with the relevant data for battery                                      
                    sto = {"T_min": heating_curveDHW[(k)*96:(k+daysForecast+1)*96], "T_max": heating_curveDHW[(k)*96:(k+daysForecast+1)*96]+deltaTmaxDHW, 
                        "init": old_T_stoDHW,"k_sto": k_sto, "A_sto": A_stoDHW,"T_amb_sto": T_amb_sto,"conv_kWh_2_K": conv_kWh_2_KDHW}                
                    # set house data
                    hou = {"heat": heatDemDHW[(k)*96:(k+daysForecast+1)*96], "congSignal":congSignal} # in kW instead of W 
                    (cop)=BESdata.efficiencyRelationsEHDHW()
                    ehdhw = {"cop":cop,"P_min": 0,"P_max": maxDemDHW*HPfactor} 
                    
                    #HERE. the actual optimization of the DHW system takes place where the MILP is called                     
                    res_dyn = optiEHDHW.optimize(ehdhw, sto, hou, co2_total, misc)   

                    #all relevant data sets are extracted                    
                    (x_dyn, heat_dyn, power_dyn, T_sto, objVal,MIPGap,Runtime,ObjBound) = res_dyn

                    #only the data sets of the respective days are further used
                    powerDHW[k*96:(k+1)*96,nHouse]=powerDHW[k*96:(k+1)*96,nHouse]+power_dyn[0:96]
                    heat_total[k*96:(k+1)*96]=heat_dyn[0:96]
                    T_sto_totalDHW[k*96:(k+1)*96]=T_sto[0:96]
                    #setting the initial storage temperature for the next day to the final storage temperature of the actual day                                      
                    old_T_stoDHW=T_sto[95]

                    print(np.size(objVal))
                    objValTotal[k-(startDay-1)]=objVal
                    MIPGapTotal[k-(startDay-1)]=MIPGap
                    RuntimeTotal[k-(startDay-1)]=Runtime
                    ObjBoundTotal[k-(startDay-1)]=ObjBound
                
                    #update grid capacities for both the feeder and the total grid
                    loadCapacityGrid[k*96:(k+1)*96]=loadCapacityGrid[k*96:(k+1)*96]-powerDHW[k*96:(k+1)*96,nHouse]/1000
                    loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[k*96:(k+1)*96,buildingFeeder[nHouse]-1]-powerDHW[k*96:(k+1)*96,nHouse]/1000

            #calculate the time for the whole calculation
            elapsed=time.time()-t
            print("Time for the whole calculation: "+str(elapsed))
        
            elapsed=time.time()-t

            save_path=target_path+"storageFactor.txt"
            np.savetxt(save_path,np.reshape(storage_factor,(1,1)))

        #HP power array is saved if at least one HP is used in optimization
        if np.sum(buildingTypes[:,0])>0:
            save_path=target_path+"powerHP.txt"
            np.savetxt(save_path, powerHP)

        #CHP power array is saved if at least one CHP is used in optimization
        if np.sum(buildingTypes[:,1])>0:            
            save_path=target_path+"powerCHP.txt"
            np.savetxt(save_path, powerCHP)
            save_path=target_path+"gasCHP.txt"
            np.savetxt(save_path, gasCHP)
        #EV power array is saved if at least one EV is used in optimization
        if np.sum(buildingTypes[:,2])>0: 
            save_path=target_path+"powerEV.txt"
            np.savetxt(save_path, powerEV)
        #Battery power array is saved if at least one battery is used in optimization
        if np.sum(buildingTypes[:,3])>0: 
            save_path=target_path+"powerBat.txt"
            np.savetxt(save_path, powerBat)
        #in case a direct electric heating is used or heat pump systems where the HR is always the backup system
        if (np.sum(buildingTypes[:,0])>0)|(np.sum(buildingTypes[:,4])>0):  
            save_path=target_path+"powerHR.txt"
            np.savetxt(save_path, powerDHW)
#        save_path=target_path+"SOCTot.txt"
#        np.savetxt(save_path, SOCtot)
#        save_path=target_path+"TStoHP.txt"
#        np.savetxt(save_path, TStoHP)
#        save_path=target_path+"heatHP.txt"
#        np.savetxt(save_path, heatHP)                     
        save_path=target_path+"loadCapacityGrid.txt"
        np.savetxt(save_path, np.transpose(loadCapacityGrid))
        save_path=target_path+"loadCapacityFeeder.txt"
        np.savetxt(save_path, loadCapacityFeeder)  
#        save_path=target_path+"penaltySignal.txt"
#        np.savetxt(save_path, penaltySignal) 

        #save the actually used CO2 signal for optimization
        save_path=target_path+"usedCO2.txt"
        np.savetxt(save_path, co2_dyn)
        
        #save the order in which the buildings are used in the optimization process
        save_path=target_path+"buildingOrder.txt"
        np.savetxt(save_path, newBuildingOrder) 
        return 1
        
def calculateInteractionSignals(loadCapacityGrid,loadCapacityFeeder,utilLimitUpper,utilLimitLower,utilLimitUpperFeeder,utilLimitLowerFeeder,buildingFeeder,co2_dyn,k,daysForecast,nHouse,weightGrid):
        #Testing, if congestions are present in the actual day
        loadCapacityGridPart=loadCapacityGrid[(k)*96:(k+daysForecast+1)*96]
        loadCapacityFeederPart=loadCapacityFeeder[(k)*96:(k+daysForecast+1)*96,buildingFeeder[nHouse]-1]            

        congSignal=np.zeros((daysForecast+1)*96,)
        co2_total=co2_dyn[(k)*96:(k+daysForecast+1)*96]        
        #scaling of co2 signal to the same dimensions as the congestion signal
        if max(co2_total)>0:        
            co2_total=co2_total/max(co2_total)
        
        congGridUpper=np.sum(loadCapacityGridPart>utilLimitUpper)
        congGridLower=np.sum(loadCapacityGridPart<utilLimitLower)
        congFeederLower=np.sum((loadCapacityFeederPart<utilLimitLowerFeeder))
        congFeederUpper=np.sum((loadCapacityFeederPart>utilLimitUpperFeeder))
        
        if len(weightGrid)==2:
            weightFullGrid=weightGrid[0]
            weightFeeder=weightGrid[1]
        else:
            weightFullGrid=weightGrid
            weightFeeder=weightGrid
        
        #adapt CO2 signal and congestion signal for optimization according to load capacities and the actual CO2 signal
        if congGridUpper>0:                    
            #congestions in a main part of the grid are present due to too high injection
            congPowerPart=(loadCapacityGridPart>utilLimitUpper)*(loadCapacityGridPart-utilLimitUpper)
            congSignal=congSignal+(1-congPowerPart/max(congPowerPart))*weightFullGrid

        if congGridLower>0:
            #congestions in a main part of the grid are present due to too high loads
            congPowerPart=(loadCapacityGridPart<utilLimitLower)*(utilLimitLower-loadCapacityGridPart)
            congSignal=congSignal+congPowerPart/max(congPowerPart)*weightFullGrid
        if congFeederLower>0:
            #congestions in a feeder of the grid are present due to too high loads
            congPowerPart=(loadCapacityFeederPart<utilLimitLowerFeeder)*(utilLimitLowerFeeder-loadCapacityFeederPart)
            congSignal=congSignal+congPowerPart/max(congPowerPart)*weightFeeder
        if congFeederUpper>0:                    
            #congestions in a feeder of the grid are present due to too high injection
            congPowerPart=(loadCapacityFeederPart>utilLimitUpperFeeder)*(loadCapacityFeederPart-utilLimitUpperFeeder)
            congSignal=congSignal+(1-congPowerPart/max(congPowerPart))*weightFeeder            
        return (co2_total,congSignal)