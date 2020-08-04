# -*- coding: utf-8 -*-
"""
Created on Thu Jan 12 18:00:50 2017

@author: ssi
"""

from multiprocessing import current_process
from multiprocessing import Pool
import time
import os
import numpy as np
import shutil
from itertools import repeat
import parmap
import sys
import run_district_func


def parallelCalculation(simulations,target,stoData,HPData,configData,inputData,parallelData,mappingProcesses):
    #find id of actual process in list of processes (this gives every process a unique number)
    found=0
    id=0
    while (found==0):
        if mappingProcesses[id]==current_process().pid:
            found=1
        id+=1
        
    target_path=target+"\\"+str(simulations+1)+"\\"
    stoData["storageFactor"]=parallelData["storageFactors"][simulations]        
#    print(stoData["storageFactor"])
    print("load capacity of the grid: "+str(parallelData["loadCapacityGrid"][0,simulations]))
    stoDataNew=stoData
    stoDataNew["storageFactor"]=parallelData["storageFactors"][simulations]
    parallelDataOpti={"runParallel":1,"storageFactor":parallelData["storageFactors"][simulations],
                      "loadCapacityGrid":parallelData["loadCapacityGrid"][:,simulations],
                      "loadCapacityFeeder":parallelData["loadCapacityFeeder"][:,:,simulations],
                        "fpe_dyn":parallelData["fpe_total"][:,simulations]}

    run_district_func.run(target_path,stoDataNew,HPData,configData,inputData,parallelDataOpti)
   
#    return "Calculation "+str(simulations)+" finished with process " +str(current_process().pid)+" and number "+str(id)+"!"
    return "Calculation "+str(simulations)+" finished with storage factor " +str(stoDataNew["storageFactor"])+"!"

if __name__ == '__main__':
    nScenarios=6
    target="D:\Ergebnisse\Optimization"  
#    vectorSimulations=map(int,sys.argv[3].split(","))
#    vectorModels=map(int,sys.argv[4].split(","))
#    copyHeatDemandFiles=int(sys.argv[5])
    sourceFolder="D:\Ergebnisse\Optimization\InputData"  

    qhouse = np.loadtxt(sourceFolder+"\q_house.txt")
    idxCalculation=np.arange(57)
    
    sourceFolder="D:\Ergebnisse\Optimization\InputData"
    t_amb=np.loadtxt(sourceFolder+"\\Wetterdaten_IBP.txt")
    t_amb=t_amb[:,2]
    
    fpe_orig = np.loadtxt(sourceFolder+"\PE_dyn.txt")
    
    #congestionPower=np.loadtxt(sourceFolder+"\congestionPower.txt")
    congestionPower=np.zeros((35040,))
    buildingFeeder=np.loadtxt(sourceFolder+"\\buildingFeeder.txt")
    #qhouse = np.loadtxt("D:\Ergebnisse\Paper_Fraunhofer\Input\dotQSH.txt")
    qhouse = np.loadtxt(sourceFolder+"\q_house.txt")
    
    qdhw=np.loadtxt(sourceFolder+"\dotQDHW.txt")
    
    buildingTypes=np.loadtxt(sourceFolder+"\\buildingTypes.txt")
    nUsers=np.loadtxt(sourceFolder+"\\nUsers.txt")

    #set all variations
    loadCapacityGrid=np.zeros((35040,nScenarios))
    loadCapacityFeeder=np.zeros((35040,np.max(buildingFeeder),nScenarios))
    for k in range(0,nScenarios):
        loadCapacityGrid[:,k]=np.loadtxt(sourceFolder+"\ALC.txt")
#        loadCapacityGrid[0,k]=0.1*k
        loadCapacityFeeder[:,:,k]=np.loadtxt(sourceFolder+"\ALCFeeder.txt")
    
    fpe_dyn=fpe_orig
    fpe_dyn[congestionPower>0]=0
    
    fpe_total=np.zeros((35040,nScenarios))
    fpe_total[:,0]=np.ones(np.size(fpe_dyn))
    fpe_total[:,1]=fpe_orig
    fpe_total[:,2]=fpe_dyn
    fpe_total[:,3]=np.ones(np.size(fpe_dyn))
    fpe_total[:,4]=fpe_orig
    fpe_total[:,5]=fpe_dyn    

    loadCapacityGrid[:,0]=np.zeros((np.size(fpe_dyn)))
    loadCapacityGrid[:,1]=np.zeros((np.size(fpe_dyn)))
    loadCapacityGrid[:,3]=np.zeros((np.size(fpe_dyn)))
    loadCapacityGrid[:,4]=np.zeros((np.size(fpe_dyn)))

    loadCapacityFeeder[:,0]=100*np.ones((35040,nScenarios))
    loadCapacityFeeder[:,1]=100*np.zeros((35040,nScenarios))
    loadCapacityFeeder[:,3]=100*np.zeros((35040,nScenarios))
    loadCapacityFeeder[:,4]=100*np.zeros((35040,nScenarios))
    storageFactors=np.array((0.5,0.5,0.5,1.,1.,1.))
    inputData = {"t_amb": t_amb, "fpe_dyn": fpe_dyn,
                 "congestionPower":np.zeros(np.size(t_amb)), "qhouse":qhouse,"qdhw":qdhw,"utilLimitUpper":0.75,"utilLimitLower":0.01}
    stoData={"delta_T_DHW":10,"delta_T_max":10,"storage_factor":1,"T_amb_sto":12,"k_sto":0.66,"k_sto_DHW":0.66}
#    HPData={"HPfactor":1.5}
    
    HPData={"HPfactor":1.0}
    configData={"daysForecast":1,"startBuilding":1,"endBuilding":57,"startDay":1,"endDay":365,"buildingTypes":buildingTypes,"nUsers":nUsers,"BESdata":1,"extraDHW":0}
    
    stoData["storage_factor"]=1
    #configData["nDays"]=10
#    configData["nBuildings"]=34
    #target_path="D:\Ergebnisse\Paper_Fraunhofer\WOCong\\"
    #run_district_func.run(target_path,stoData,HPData,configData,inputData)
    
    inputData["loadCapacityGrid"]=loadCapacityGrid[:,0]
    inputData["loadCapacityFeeder"]=loadCapacityFeeder[:,:,0]
    inputData["buildingFeeder"]=buildingFeeder
    nProcesses=6
    nSimTot=nScenarios
#    storageFactors=(np.arange(nSimTot)+1)
    parallelData={"storageFactors":storageFactors,"loadCapacityGrid":loadCapacityGrid,"loadCapacityFeeder":loadCapacityFeeder,"fpe_total":fpe_total}    
    target_path="D:\Ergebnisse\Optimization"    
    for k in range(0,nSimTot):    
        target_path_tot=target_path+"\\"+str(k+1)+"\\"
        if not os.path.exists(target_path_tot):
            os.makedirs(target_path_tot)

    scenarios=(np.arange(nSimTot))

    t=time.time()
    p=Pool(nProcesses)
    id=0
    #array mappingProcesses is needed to get an explicit mapping of processes to the heatDemand files during simulation
    mappingProcesses=np.zeros(nProcesses)
    for _curr_process in p._pool[:]:
            print("This is process "+ str(_curr_process.pid))
            mappingProcesses[id]=_curr_process.pid
            id+=1
          
    print(mappingProcesses) 

    #the simulation itself (see above) => package parmap is needed     
    y = parmap.starmap(parallelCalculation, zip(scenarios),target_path,stoData,HPData,configData,inputData,parallelData,mappingProcesses, pool=p) 
#    print(y)
    elapsed=time.time()-t
    print(elapsed)    
    target_path_time=target_path+"\\timeParallel.txt"
    np.savetxt(target_path_time,np.reshape(elapsed,(1,1)))
#    t=time.time()        
#    parallelDataOpti={"runParallel":0}
#    for k in range(0,nSimTot):
#        stoData["storage_factor"]=storageFactors[k]/5.0
#        target_path_tot=target_path+"\\"+str(k+1)+"\\"
#        run_district_func.run(target_path_tot,stoData,HPData,configData,inputData,parallelDataOpti)
#    
#    elapsed=time.time()-t
#    print(elapsed) 
#    target_path_time=target_path+"\\timeSequence.txt"
#    np.savetxt(target_path_time,np.reshape(elapsed,(1,1)))