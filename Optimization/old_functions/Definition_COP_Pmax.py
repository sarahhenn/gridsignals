# -*- coding: utf-8 -*-
"""
Created on Fri May 13 13:40:57 2016

@author: kklein
"""
import numpy as np

def COP(T_source,T_sink,HPtype):
    from scipy.interpolate import Rbf    
    Vectorinput = not (isinstance(T_source,np.float64) or isinstance(T_source,float) or isinstance(T_source,int))
    # Definition of lookuptable
    x = np.array([-15,-7,2,7,20,30,   -15,-7,2,7,20,30,  -15,-7,2,7,20,30],dtype='float') #T_source
    if HPtype =='Vitocal201A07':
        y = np.array([35,35,35,35,35,35,   45,45,45,45,45,45,  55,55,55,55,55,55],dtype='float') # T_sink
        z = np.array([2.23,2.82,3.76,4.77,6.53,7.97,  1.78,2.35,2.98,3.58,4.67,5.52,  1.16,1.88,2.33,2.76,4.03,5.01],dtype='float') # COP    
    elif HPtype == 'VitocalAWH351A10':
        y = np.array([35,35,35,35,35,35,   45,45,45,45,45,45,  65,65,65,65,65,65],dtype='float') # T_sink        
        z = np.array([2.54,2.97,3.5,4.02,4.89,5.93,   2.20,2.54,2.97,3.43,4.09,4.85,     1.8,1.96,2.41,2.7,3.05,3.44],dtype='float') # COP     ### CHANGE VALUES TO DIFFERENT CHAR: CURVES
    rbf = Rbf(x,y,z,function='linear') # Interpolation function
    
    if Vectorinput == True:
        COP =np.zeros((len(T_source)))
        for i in range(len(T_source)):
            if T_sink[i] <= 55 and T_sink[i] > 35:
                COP[i] = rbf(T_source[i],T_sink[i])
            elif T_sink[i] > 55:
                COP_45 = rbf(T_source[i],45); COP_55 = rbf(T_source[i],55)
                COP[i] = COP_55 + (T_sink[i]-55) * (COP_55-COP_45)/(55-45)
            else:
                COP_35 = rbf(T_source[i],35); COP_45 = rbf(T_source[i],45)
                COP[i] = COP_35 + (T_sink[i]-35) * (COP_35-COP_45)/(35-45)
    else:
        if T_sink <= 55 and T_sink > 35:
            COP = rbf(T_source,T_sink)
        elif T_sink > 55:
            COP_45 = rbf(T_source,45); COP_55 = rbf(T_source,55)
            COP = COP_55 + (T_sink-55) * (COP_55-COP_45)/(55-45)
        else:
            COP_35 = rbf(T_source,35); COP_45 = rbf(T_source,45)
            COP = COP_35 + (T_sink-35) * (COP_35-COP_45)/(35-45)
    return(COP)
    
def Pmax(T_source,T_sink,HPtype):
    from scipy.interpolate import Rbf    
    Vectorinput = not (isinstance(T_source,np.float64) or isinstance(T_source,float) or isinstance(T_source,int))

    # Definition of lookuptable
    x = np.array([-15,-7,2,7,20,30,   -15,-7,2,7,20,30,  -15,-7,2,7,20,30],dtype='float') #T_source
    
    if HPtype =='Vitocal201A07':
        y = np.array([35,35,35,35,35,35,   45,45,45,45,45,45,  55,55,55,55,55,55],dtype='float') # T_sink
        z = np.array([2.23,2.64,1.32,1.08,1.02,0.95,  2.54,3.1,1.58,1.4,1.34,1.3,  1.73,1.86,1.93,1.64,1.27,1.02],dtype='float') # Pel_max    
    elif HPtype == 'VitocalAWH351A10':
        y = np.array([35,35,35,35,35,35,   45,45,45,45,45,45,  65,65,65,65,65,65],dtype='float') # T_sink        
        z = np.array([2.91,3.03,3.08,3.19,3.24,3.28,    3.43,3.58,3.75,3.90,3.98,4.04,     5,5.05,5.22,5.35,5.42,5.48],dtype='float') # Pel_max
    # Interpolation function
    rbf = Rbf(x,y,z,function='linear')    
    if Vectorinput == True:
        Pmax =np.zeros((len(T_source)))
        for i in range(len(T_source)):
            if T_sink[i] <= 55 and T_sink[i] > 35:
                Pmax[i] = rbf(T_source[i],T_sink[i])
            elif T_sink[i] > 55:
                Pmax_45 = rbf(T_source[i],45); Pmax_55 = rbf(T_source[i],55)
                Pmax[i] = Pmax_55 + (T_sink[i]-55) * (Pmax_55-Pmax_45)/(55-45)
            else:
                Pmax_35 = rbf(T_source[i],35); Pmax_45 = rbf(T_source[i],45)
                Pmax[i] = Pmax_35 + (T_sink[i]-35) * (Pmax_35-Pmax_45)/(35-45)
    else:
        if T_sink <= 55 and T_sink > 35:
            Pmax = rbf(T_source,T_sink)
        elif T_sink > 55:
            Pmax_45 = rbf(T_source,45); Pmax_55 = rbf(T_source,55)
            Pmax = Pmax_55 + (T_sink-55) * (Pmax_55-Pmax_45)/(55-45)
        else:
            Pmax_35 = rbf(T_source,35);  Pmax_45 = rbf(T_source,45)
            Pmax = Pmax_35 + (T_sink-35) * (Pmax_35-Pmax_45)/(35-45)
    return(Pmax)