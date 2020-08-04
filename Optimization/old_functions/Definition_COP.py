# -*- coding: utf-8 -*-
"""
Created on Aug 09 2016

@author: ssi
"""
import numpy as np

def COP(T_source,T_sink,HPtype,qualityGrade):
    Vectorinput = not (isinstance(T_source,np.float64) or isinstance(T_source,float) or isinstance(T_source,int))
    # Definition of lookuptable
   
    if Vectorinput == True:
        COP =np.zeros((len(T_source)))
        for i in range(len(T_source)):
            COP[i] = qualityGrade*(T_sink[i]+273.15)/(T_sink[i]-T_source[i])
            
    else:
        COP = qualityGrade*(T_sink+273.15)/(T_sink-T_source)

    return(COP)
    