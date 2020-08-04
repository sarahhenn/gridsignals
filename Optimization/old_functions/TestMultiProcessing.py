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

def f(simulations,models,target,mappingProcesses,copyHeatDemandFiles):
    #find id of actual process
    found=0
    id=0
    while (found==0):
        if mappingProcesses[id]==current_process().pid:
            found=1
        id+=1
            
    if copyHeatDemandFiles==1:
        src=target+"\\HeatDemandFiles\\HeatDemand_"
        dest=target+"\\HeatDemandFiles\\HeatDemandSim_"
        shutil.copyfile(src+str(simulations)+".mat",dest+str(models)+".mat")
    exePart=target+"dsin_files\\dymosim_"+str(models)+".exe -w "
    logPart=target+"log\\dslog_"+str(simulations)+".txt "
    dsinPart=target+"dsin_files\dsin_"+str(simulations)+".mat "
    resPart=target+"results\dsres_"+str(simulations)+".mat"
    executionString=exePart+logPart+dsinPart+resPart
    print(executionString)
    os.system(executionString) 
    return "Simulation "+str(simulations)+" finished with process " +str(current_process().pid)+" and number "+str(id)+"!"

if __name__ == '__main__':
    target=sys.argv[1]   
    vectorSimulations=map(int,sys.argv[2].split(","))
    vectorModels=map(int,sys.argv[3].split(","))
    copyHeatDemandFiles=int(sys.argv[4])
    t=time.time()
    #print(vectorSimulations)
#    vectorSimulations=numpy.linspace(start=1,stop=24,num=24,dtype='int16')
#    vectorModels=numpy.ones(24,dtype='int16')
#    target="D:\\Ergebnisse\\TestParallel\\"
   
    p=Pool(12)
    id=0
    mappingProcesses=numpy.zeros(12)
    for _curr_process in p._pool[:]:
            print("This is process "+ str(_curr_process.pid))
            mappingProcesses[id]=_curr_process.pid
            id+=1
          
    print(mappingProcesses)      
    y = parmap.starmap(f, zip(vectorSimulations,vectorModels),target,mappingProcesses,copyHeatDemandFiles, pool=p) 
    print(y)
    elapsed=time.time()-t
    print(elapsed)