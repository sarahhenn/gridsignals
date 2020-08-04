# -*- coding: utf-8 -*-
"""
Created on Fri Jan 13 14:24:25 2017

@author: ssi
"""
import numpy as np
import Definition_COP_Pmax as defCOP
def defineBESData(typeBES,stoData,t_amb,totalSH,storageFactor):

    if typeBES=='HP':    
        deltaTmax=10
    elif typeBES=='CHP':
        deltaTmax=45
    elif typeBES=='EHDHW':
        deltaTmax=55

    heating_curve=45*np.ones((np.size(t_amb)))
    sto_vol=storageFactor*totalSH/365/(stoData["rho"]*stoData["cp"]*deltaTmax*stoData["conv_kJ_2_kWh"])
    sto_height=(1./np.pi)*(sto_vol**(1./3))
            
    #surface area consists of shell surface and top and bottom                
    A_sto=np.sqrt(4*sto_vol*np.pi*sto_height)+2*sto_vol/sto_height
    #a conversion factor for this storage is needed to convert every kWh 
    #of energy into Kelvins of temperature change
    conv_kWh_2_K=1/(stoData["rho"]*stoData["cp"]*sto_vol*stoData["conv_kJ_2_kWh"])   

   
    return (heating_curve,sto_vol,A_sto,deltaTmax,conv_kWh_2_K)
    
    
def efficiencyRelationsHP(HPfactor,t_amb,heating_curve,delta_T_max,maxDem,daysForecast):
    cop=np.zeros((daysForecast+1)*96,)
    p_el=np.zeros((daysForecast+1)*96,)
    for k in range(0,np.size(t_amb,)):        
        cop[k]= defCOP.COP(t_amb[k],heating_curve[k]+delta_T_max/2,'free') 
        p_el[k]=maxDem/cop[k]*HPfactor
    return (cop,p_el)
    
def efficiencyRelationsCHP(HPfactor,maxDem):
    etael=0.3
    etath=0.6
    etaBoi=0.95
    print("efficiency relations for CHP need to be changed") 
    
    Pelmax=maxDem*HPfactor*etael/etath
    
    return (etael,etath,etaBoi,Pelmax)
    
def efficiencyRelationsEHDHW():
    cop=0.99
    print("efficiency relations for EHDHW need to be changed") 
    
    return (cop)    
