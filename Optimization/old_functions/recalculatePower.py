# -*- coding: utf-8 -*-
"""
Created on Tue Aug 02 12:45:30 2016

@author: ssi
"""
import Definition_COP as defCOP
import numpy as np


def run(heat_profile,sourceTemp,sinkTemp,HPtype,qualityGrade):
    
    power_profile=np.zeros(np.size(heat_profile))
    cop=np.zeros(np.size(heat_profile))       
    for k in range(0,np.size(heat_profile,0)):
        cop[k]= defCOP.COP(sourceTemp[k],sinkTemp[k],HPtype,qualityGrade)
        power_profile[k]=heat_profile[k]/cop[k]
        
    return power_profile