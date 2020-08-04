# -*- coding: utf-8 -*-
"""
Created on Wed Jul 06 18:47:13 2016

@author: ssi
"""
import numpy as np
import time
import Definition_COP_Pmax as defCOP

#t_storage=np.zeros(35040,)
#t_start=0.9128/(rho*sto_vol*cp*conv_kJ_2_kWh)+heating_curve[0]
#t_storage[0]=t_start+(heat_total[0]-heatDem[0]/1000-k_storage*A*(t_start-T_amb_sto)/1000)*misc["dt"]/(rho*sto_vol*cp*conv_kJ_2_kWh)
#t_storage=heating_curve[0:35040]+energy_total/(rho*sto_vol*cp*conv_kJ_2_kWh)-5
#power_new=np.zeros(35040,)

ISEdata=np.loadtxt("../Input/ISEdata.txt")
t_amb=np.loadtxt("..\Input\TRY2010_13_Jahr.dat", skiprows=38, usecols=(8,9))
t_amb=t_amb[:,0]
t_amb=np.interp(np.linspace(0,8760,35041),np.linspace(0,8760,8761),t_amb)
HPtype ='Vitocal201A07'
heatISE=np.zeros(35040,)

for k in range(0,35040):
#    t_storage[k]=t_storage[k-1]+(heat_total[k]-heatDem[k]/1000-k_storage*A*(t_storage[k-1]-T_amb_sto)/1000)*misc["dt"]/(rho*sto_vol*cp*conv_kJ_2_kWh)
#    if power_total[k]>0:
#        actCOP= defCOP.COP(t_amb[k],t_storage[k-1],HPtype)
#        power_new[k]=heat_total[k]/actCOP
#    else:
#        power_new[k]=power_total[k
    if ISEdata[k,0]>0:
        actCOP=defCOP.COP(t_amb[k-1],ISEdata[k-1,1]+2,HPtype)    
        heatISE[k]=actCOP*ISEdata[k,0]
    else:
        heatISE[k]=0


#np.savetxt("comparison.txt", np.transpose(np.vstack((power_total,t_storage,heating_curve[0:35040]))), delimiter='\t')

    