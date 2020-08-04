# -*- coding: utf-8 -*-
"""
Created on Thu Apr 07 15:35:38 2016

@author: tsz,ssi
"""
from __future__ import division

import optimization_model_PE as opti
#import optimization_model_one_storage as opti


import numpy as np
import time
import Definition_COP_Pmax as defCOP
import BESdata

def run(target_path,stoData,HPData,configData,inputData,parallelData):
    
        t=time.time()
        
        #load HP config data
        buildingTypes=configData["buildingTypes"]
        nUsers=configData["nUsers"] 
        startBuilding=configData["startBuilding"]     
        endBuilding=configData["endBuilding"]
        startDay=configData["startDay"]     
        endDay=configData["endDay"]  
        nBuildings=endBuilding-startBuilding+1    
        daysForecast=configData["daysForecast"]  
        nDays=endDay-startDay+1
        # Load weather data
        t_amb=inputData["t_amb"]
        t_amb = np.concatenate((t_amb,t_amb[1:(daysForecast*96)+1]))
        
        # load storage data   
        rho = 1000 # kg/m3
        cp = 4.180 # kJ/kgK
        conv_kJ_2_kWh = 1 / 3600
        
        stoData["rho"]=rho
        stoData["cp"]=cp
        stoData["conv_kJ_2_kWh"]=conv_kJ_2_kWh
        DHW_temperature=45
        delta_T_DHW=stoData["delta_T_DHW"]
        delta_T_max=stoData["delta_T_max"]
        if parallelData["runParallel"]==1:       
            storage_factor=parallelData["storageFactor"]      
            stoData["storageFactor"]=storage_factor
        else:               
            storage_factor=stoData["storage_factor"]
        T_amb_sto=stoData["T_amb_sto"]
        k_sto=stoData["k_sto"]
        k_sto_DHW=stoData["k_sto_DHW"]
        
        HPfactor=HPData["HPfactor"]    
        
        # load fpe inputs
        if parallelData["runParallel"]==1:
            fpe_dyn=parallelData["fpe_dyn"]
        else:
            fpe_dyn=inputData["fpe_dyn"]    
        fpe_dyn = np.concatenate((fpe_dyn,fpe_dyn[1:(daysForecast*96)+1]))
        if parallelData["runParallel"]==1:
            loadCapacityGrid=parallelData["loadCapacityGrid"]
        else:
            loadCapacityGrid=inputData["loadCapacityGrid"]
        loadCapacityGrid= np.concatenate((loadCapacityGrid,loadCapacityGrid[1:(daysForecast*96)+1]))
        loadCapacityFeeder=inputData["loadCapacityFeeder"]
        loadCapacityFeeder= np.concatenate((loadCapacityFeeder,loadCapacityFeeder[1:(daysForecast*96)+1,:]))
        utilLimitUpper=inputData["utilLimitUpper"]        
        utilLimitLower=inputData["utilLimitLower"] 
        buildingFeeder=inputData["buildingFeeder"]
        
        heatDemWhole = inputData["qhouse"]
        heatDemWhole = np.concatenate((heatDemWhole,heatDemWhole[97:(daysForecast*96)+97,:]))
       
        heatDHWWhole=inputData["qdhw"]  
        heatDHWWhole = np.concatenate((heatDHWWhole,heatDHWWhole[97:(daysForecast*96)+97,:]))
         
        for nHouse in range(startBuilding-1,endBuilding):       
#        for nHouse in range(0,nBuildings):
            #heat demand for the single building
            heatDem=heatDemWhole[:,nHouse]
            heatDHW=heatDHWWhole[:,nHouse]
            totalSH=np.sum(heatDem)/4
            maxDem=np.max(heatDem+heatDHW)
            totalDHW=np.sum(heatDHW)/4
            configData["actHouse"]=nHouse
            (HPtype,heating_curve,sto_vol,sto_height,sto_vol_DHW,sto_height_DHW)=BESdata.defineBESData(configData,stoData,t_amb,totalSH,totalDHW)

            sto_vol=storage_factor*sto_vol
            sto_vol_DHW=storage_factor*sto_vol_DHW
            
            #surface area consists of shell surface and top and bottom                
            A_sto=np.sqrt(4*sto_vol*np.pi*sto_height)+2*sto_vol/sto_height
            #a conversion factor for this storage is needed to convert every kWh 
            #of energy into Kelvins of temperature change
            conv_kWh_2_K=1/(rho*cp*sto_vol*conv_kJ_2_kWh)   
             
            #surface area consists of shell surface and top and bottom                
            A_sto_DHW=np.sqrt(4*sto_vol_DHW*np.pi*sto_height_DHW)+2*sto_vol_DHW/sto_height_DHW
            #a conversion factor for this storage is needed to convert every kWh 
            #of energy into Kelvins of temperature change
            conv_kWh_2_K_DHW=1/(rho*cp*sto_vol_DHW*conv_kJ_2_kWh) 
#            nDays=40
            #initialize all output variables
            power_total=np.zeros(0,)
            T_sto_total=np.zeros(0,)
            power_DHW_total=np.zeros(0,)
            T_sto_total_DHW=np.zeros(0,)
            heat_total=np.zeros(0,)
            heat_DHW_total=np.zeros(0,)
            objValTotal=np.zeros(nDays,)
            MIPGapTotal=np.zeros(nDays,)
            RuntimeTotal=np.zeros(nDays,)
            ObjBoundTotal=np.zeros(nDays,)
            
            #initialize storage temperatures 
            old_T_sto=heating_curve[0]+delta_T_max/2
            old_T_sto_DHW=DHW_temperature+delta_T_DHW/2
        
#            congSignalTotal=1-congestionPower/max(congestionPower)
            for k in range(startDay-1,endDay):
                print("This is house " +str(nHouse+1)+" and days " + str(k+1))
                #inititalize hp data
                cop=np.zeros((daysForecast+1)*96,)
                p_el=np.zeros((daysForecast+1)*96,)
                cop_dhw=np.zeros((daysForecast+1)*96,)
                p_el_dhw=np.zeros((daysForecast+1)*96,)
               
                
                for m in range((k)*96,(k+daysForecast+1)*96):
                    cop[m-k*96]= defCOP.COP(t_amb[m],heating_curve[m]+delta_T_max/2,HPtype) 
                    if configData["BESdata"]==1:                    
                        p_el[m-k*96]=maxDem/cop[m-k*96]*HPfactor
                    elif configData["BESdata"]==2:                        
                        p_el[m-k*96]= defCOP.Pmax(t_amb[m],heating_curve[m]+delta_T_max/2,HPtype)*HPfactor
                    cop_dhw[m-k*96]= defCOP.COP(t_amb[m],DHW_temperature+delta_T_DHW/2,HPtype) 
                    if configData["BESdata"]==1:
                        p_el_dhw[m-k*96]=maxDem/cop_dhw[m-k*96]*HPfactor
                    elif configData["BESdata"]==2: 
                        p_el_dhw[m-k*96]= defCOP.Pmax(t_amb[m],DHW_temperature+delta_T_DHW/2,HPtype)*HPfactor           
               
        
                hp = {"cop": cop, "P_min": np.zeros(np.size(p_el)),"P_max": p_el,
                      "cop_DHW": cop_dhw,"P_min_DHW":np.zeros(np.size(p_el_dhw)),"P_max_DHW":p_el_dhw}
                             
                sto = {"T_min": heating_curve[(k)*96:(k+daysForecast+1)*96], "T_max": heating_curve[(k)*96:(k+daysForecast+1)*96]+delta_T_max, 
                       "init": old_T_sto,"k_sto": k_sto, "A_sto": A_sto, 
                       "T_amb_sto": T_amb_sto,"conv_kWh_2_K": conv_kWh_2_K,
                       "T_min_DHW": DHW_temperature*np.ones(np.size(heating_curve[(k)*96:(k+daysForecast+1)*96])), 
                       "T_max_DHW": DHW_temperature*np.ones(np.size(heating_curve[(k)*96:(k+daysForecast+1)*96]))+delta_T_DHW,                    
                       "init_DHW": old_T_sto_DHW,"k_sto_DHW": k_sto_DHW, "A_sto_DHW": A_sto_DHW, 
                       "conv_kWh_2_K_DHW": conv_kWh_2_K_DHW}
                
                #Testing, if congestions are present in the actual day
                loadCapacityGridPart=loadCapacityGrid[(k)*96:(k+daysForecast+1)*96]
                loadCapacityFeederPart=loadCapacityFeeder[(k)*96:(k+daysForecast+1)*96,buildingFeeder[nHouse]-1]            

#                if np.sum(congestionPower[(k)*96:(k+daysForecast+1)*96])==0:
                if np.sum((loadCapacityGridPart>utilLimitUpper)|(loadCapacityFeederPart<utilLimitLower))==0:
                    congSignal=np.zeros((daysForecast+1)*96,)
                    fpe_total=fpe_dyn[(k)*96:(k+daysForecast+1)*96]
#                    print("no congestions present!!!")
                elif np.sum((loadCapacityGridPart>utilLimitUpper))>0:
#                    congSignal=congSignalTotal[(k)*96:(k+daysForecast+1)*96]
                    congPowerPart=(loadCapacityGridPart>utilLimitUpper)*(loadCapacityGridPart-utilLimitUpper)
                    congSignal=(1-congPowerPart/max(congPowerPart))*5
                    fpe_total=fpe_dyn[(k)*96:(k+daysForecast+1)*96]
                    fpe_total[congPowerPart>utilLimitUpper]=0
                else:
                    congPowerPart=(loadCapacityFeederPart<utilLimitLower)*(utilLimitLower-loadCapacityFeederPart)
                    congSignal=congPowerPart/max(congPowerPart)*5
                    fpe_total=fpe_dyn[(k)*96:(k+daysForecast+1)*96]
                    
                # load house data
                hou = {"heat": heatDem[(k)*96:(k+daysForecast+1)*96] ,"heat_DHW": heatDHW[(k)*96:(k+daysForecast+1)*96],"congSignal":congSignal} # in kW instead of W
                
                misc = {"dt" : 0.25, # quarter hourly sampling
                        "time steps" : (daysForecast+1)*96, "extraDHW": configData["extraDHW"]}
                         
                res_dyn = opti.optimize(hp, sto, hou, fpe_total, misc)
        
                (x_dyn, heat_dyn,heat_DHW, power_dyn,power_DHW, T_sto,T_sto_DHW, objVal,MIPGap,Runtime,ObjBound) = res_dyn
                power_total=np.concatenate((power_total,power_dyn[0:96]))
                power_DHW_total=np.concatenate((power_DHW_total,power_DHW[0:96]))
                heat_total=np.concatenate((heat_total,heat_dyn[0:96]))
                heat_DHW_total=np.concatenate((heat_DHW_total,heat_DHW[0:96]))
                T_sto_total=np.concatenate((T_sto_total,T_sto[0:96]))
                T_sto_total_DHW=np.concatenate((T_sto_total_DHW,T_sto_DHW[0:96]))
                old_T_sto=T_sto_total[-1]
                old_T_sto_DHW=T_sto_total_DHW[-1]
                print(np.size(objVal))
                objValTotal[k-(startDay-1)]=objVal
                MIPGapTotal[k-(startDay-1)]=MIPGap
                RuntimeTotal[k-(startDay-1)]=Runtime
                ObjBoundTotal[k-(startDay-1)]=ObjBound
                
            
            loadCapacityGrid[(startDay-1)*96:endDay*96]=loadCapacityGrid[(startDay-1)*96:endDay*96]-power_total/1000-power_DHW_total/1000
            loadCapacityFeeder[(startDay-1)*96:endDay*96,buildingFeeder[nHouse]-1]=loadCapacityFeeder[(startDay-1)*96:endDay*96,buildingFeeder[nHouse]-1]-power_total/1000-power_DHW_total/1000
#            loadCapacity[congestionPower<0]=0
            elapsed=time.time()-t
#            print("Time for the whole calculation: "+str(elapsed))
            save_path=target_path+"RWTH_"+str(nHouse+1)+".txt"
            np.savetxt(save_path, np.transpose(np.vstack((power_total,power_DHW_total,T_sto_total,T_sto_total_DHW,heat_total,heat_DHW_total))), delimiter='\t')
        
            elapsed=time.time()-t
            save_path2=target_path+"Error_"+str(nHouse+1)+".txt"
            np.savetxt(save_path2, np.transpose(np.vstack((objValTotal,MIPGapTotal,RuntimeTotal,ObjBoundTotal))), delimiter='\t')
            save_path3=target_path+"storageFactor.txt"
            np.savetxt(save_path3,np.reshape(storage_factor,(1,1)))
         
#        print("Time for the whole calculation + storing the data: "+str(elapsed))
        return 1