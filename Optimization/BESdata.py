# -*- coding: utf-8 -*-
"""
Created on Fri Jan 13 14:24:25 2017

@author: ssi
"""
import numpy as np
def defineBESData(configData,stoData,t_amb,totalSH,totalDHW):
    actHouse=configData["actHouse"]    
    if configData["BESdata"]==1:
        HPtype='free'
        heating_curve=45*np.ones((np.size(t_amb)))
        if configData["extraDHW"]==1:        
            sto_vol=totalSH/365/(stoData["rho"]*stoData["cp"]*stoData["delta_T_max"]*stoData["conv_kJ_2_kWh"])
            sto_height=(1./np.pi)*(sto_vol**(1./3))
            sto_vol_DHW=totalDHW/365/(stoData["rho"]*stoData["cp"]*stoData["delta_T_DHW"]*stoData["conv_kJ_2_kWh"])
            sto_height_DHW=(1./np.pi)*(sto_vol_DHW**(1./3))
        else:
            sto_vol=(totalSH+totalDHW)/365/(stoData["rho"]*stoData["cp"]*stoData["delta_T_max"]*stoData["conv_kJ_2_kWh"])
            sto_height=(1./np.pi)*sto_vol**(1./3)
            sto_vol_DHW=0
            sto_height_DHW=0
        
    if configData["BESdata"]==2:    
        if configData["buildingTypes"][actHouse]==1:
            HPtype ='Vitocal201A07'
            heating_curve=-0.0036*(t_amb*t_amb)-0.3929*t_amb+26.5   
            sto_vol = 1 # m3
            sto_height=2.04 #m        
            if configData["nUsers"][actHouse]>3:        
                sto_vol_DHW=0.6 # m3
                sto_height_DHW=1.334 #m
            else:
                sto_vol_DHW=0.3 # m3
                sto_height_DHW=0.997 #m
                
        elif configData["buildingTypes"][actHouse]==2:
            HPtype = 'VitocalAWH351A10'
            heating_curve=-0.0036*(t_amb*t_amb)-0.3929*t_amb+26.5
            sto_vol=1.5 # m3      
            sto_height=2.15 #m               
            sto_vol_DHW=1 # m3       
            sto_height_DHW=1.961 #m
        
        elif configData["buildingTypes"][actHouse]==3:
            HPtype ='Vitocal201A07'
            heating_curve=-0.0036*(t_amb*t_amb)-0.3929*t_amb+26.5
            sto_vol = 1 # m3
            sto_height=2.04 #m
            if configData["nUsers"][actHouse]>3:        
                sto_vol_DHW=0.6 # m3
                sto_height_DHW=1.334 #m
            else:
                sto_vol_DHW=0.3 # m3 
                sto_height_DHW=0.997 #m  
                
        elif configData["buildingTypes"][actHouse]==4:
            HPtype = 'VitocalAWH351A10'
            heating_curve=-0.0036*(t_amb*t_amb)-0.3929*t_amb+25
            sto_vol=1.5 # m3      
            sto_height=2.15 #m               
            sto_vol_DHW=1 # m3       
            sto_height_DHW=1.961 #m
            
        else:
            HPtype = 'Vitocal201A07'
            heating_curve=-0.0036*(t_amb*t_amb)-0.3929*t_amb+25
            
            sto_vol=1 #m3
            sto_height=2.04 #m
            
            if configData["nUsers"][actHouse]>3:        
                sto_vol_DHW=0.6 # m3
                sto_height_DHW=1.334 #m
            else:
                sto_vol_DHW=0.3 # m3 
                sto_height_DHW=0.997 #m
    
    return (HPtype,heating_curve,sto_vol,sto_height,sto_vol_DHW,sto_height_DHW)