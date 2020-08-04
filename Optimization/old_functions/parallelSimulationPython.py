# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 13:32:22 2016

@author: ssi
"""
from multiprocessing import current_process
from multiprocessing import Pool
import time
import os
import numpy
import shutil
from itertools import repeat
import parmap
import sys

def parallelSimulation(simulations,models,target,mappingProcesses,copyHeatDemandFiles):
    #find id of actual process in list of processes (this gives every process a unique number)
    found=0
    id=0
    while (found==0):
        if mappingProcesses[id]==current_process().pid:
            found=1
        id+=1

    #in case a heatDemandFile variation is necessary, the files are copied from the original file
    #to the simulation file (with the unique number of the process)           
    if copyHeatDemandFiles==1:
        src=target+"\\HeatDemandFiles\\HeatDemand_"
        dest=target+"\\HeatDemandFiles\\HeatDemandSim_"
        shutil.copyfile(src+str(simulations)+".mat",dest+str(id)+".mat")
    
    #different parts of the execution string are generated and the concatenated    
    exePart=target+"dsin_files\\dymosim_"+str(id)+".exe -w "
    logPart=target+"log\\dslog_"+str(simulations)+".txt "
    dsinPart=target+"dsin_files\dsin_"+str(simulations)+".mat "
    resPart=target+"results\dsres_"+str(simulations)+".mat"
    executionString=exePart+logPart+dsinPart+resPart
    print(executionString)
    #the simulation itself
    os.system(executionString) 
    return "Simulation "+str(simulations)+" finished with process " +str(current_process().pid)+" and number "+str(id)+"!"

if __name__ == '__main__':
    nProcesses=int(sys.argv[1])    
    target=sys.argv[2]   
    vectorSimulations=map(int,sys.argv[3].split(","))
    vectorModels=map(int,sys.argv[4].split(","))
    copyHeatDemandFiles=int(sys.argv[5])
    t=time.time()

    p=Pool(nProcesses)
    id=0
    #array mappingProcesses is needed to get an explicit mapping of processes to the heatDemand files during simulation
    mappingProcesses=numpy.zeros(nProcesses)
    for _curr_process in p._pool[:]:
            print("This is process "+ str(_curr_process.pid))
            mappingProcesses[id]=_curr_process.pid
            id+=1
          
    print(mappingProcesses) 
    #the simulation itself (see above) => package parmap is needed     
    y = parmap.starmap(parallelSimulation, zip(vectorSimulations,vectorModels),target,mappingProcesses,copyHeatDemandFiles, pool=p) 
    print(y)
    elapsed=time.time()-t
    print(elapsed)