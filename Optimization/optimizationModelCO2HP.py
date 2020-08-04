# -*- coding: utf-8 -*-
"""
Created on Thu Apr 07 15:06:43 2016

@author: tsz
"""
from __future__ import division

import gurobipy as gp
import numpy as np

def optimize(hp, sto, hou, co2, misc):
    """
    Parameters
    ----------
    hp : dictionary with heat pump definitions
        - P_min : array of float [kW]
        - P_max : array of float [kW]
    sto : dictionary with storage definitions
        - T_min : float [°C] - minimum storage temperature
        - T_max : float [°C] - maximum storage temperature
        - init : float [°C] - initial storage temperature
        - k_sto : float [W/(m²K)] - storage loss coefficient
        - A_sto : float [m²] - outer surface area of storage
        - T_amb_sto: float[°C] - ambient temperature of storage
        - conv_kWh_2_K: float [K/kWh] - conversion factor to calculate temperature difference resulting from energy
    hou : dictionary with house inputs
        - heat : array heat demand in kW
        - dhw: array DHW demand in kW (if DHW demand present)
    fpe : array
        Primary energy coefficients
    misc : dictionary with miscellaneous data
        - dt : integer - time discretization in seconds
        - time steps : integer - number of time steps
    """
    model = gp.Model("HP operation optimization with time-resolved CO2 factors")
    
    x = {} # HP activation for space heating
    temperature = {} # Storage temperature
    heat = {} # Heat production HP
    power = {} # Power consumption HP
    powerCorr={} #corrected power consumption of HP
    powerHR={} # possible power of HR
    for t in range(misc["time steps"]):
        x[t] = model.addVar(vtype="B", name="activation_"+str(t))
        temperature[t] = model.addVar(vtype="C", name="temperature_"+str(t))
        heat[t] = model.addVar(vtype="C", name="heat_"+str(t))
        power[t] = model.addVar(vtype="C", name="power_"+str(t))
        powerCorr[t] = model.addVar(vtype="C", name="powerCorr_"+str(t))   
        powerHR[t] = model.addVar(vtype="C", name="powerHR_"+str(t))   
    model.update()
    
    model.setObjective(sum(((co2[t]+hou["congSignal"][t]) * (powerCorr[t] + powerHR[t])) for t in range(misc["time steps"])),
                           gp.GRB.MINIMIZE)
                           
    for t in range(misc["time steps"]):
        model.addConstr(temperature[t] <= sto["T_max"][t], name="max sto cap_"+str(t))
        model.addConstr(temperature[t] >= sto["T_min"][t], name="min sto cap_"+str(t))


            
    for t in range(misc["time steps"]):
        if t == 0:
            temperature_previous = sto["init"]

        else:
            temperature_previous = temperature[t-1]

                
        model.addConstr(temperature[t] == (temperature_previous + 
                                     misc["dt"] * sto["conv_kWh_2_K"] *
                                     (heat[t] + powerHR[t] - hou["heat"][t]
                                     -sto["k_sto"]*sto["A_sto"]*(temperature_previous-sto["T_amb_sto"])/1000)),
                        name="storage balance_"+str(t))
    
    for t in range(misc["time steps"]):
        model.addConstr(heat[t] == hp["cop"][t] * power[t], 
                        name="Coupling heat and power_"+str(t))
                    
    for t in range(misc["time steps"]):
        model.addConstr(power[t] >= x[t] * hp["P_min"][t], name="min power_"+str(t))
        model.addConstr(power[t] <= x[t] * hp["P_max"][t], name="max power_"+str(t))
        #calculating the power including the correction of the HP power with the temperature increase
        model.addConstr(powerCorr[t] == power[t] + (temperature[t]-sto["T_min"][t])*hp["corrFactor"][t], name="power correction_"+str(t))
        #heat of HR can only be used if heat of HP is already in use
        model.addConstr(powerHR[t]<=heat[t],name="operation restriction HR_"+str(t))
        
    model.addConstr(sum(powerHR[t] for t in range(misc["time steps"])) <= 0.02*(sum(powerHR[t] for t in range(misc["time steps"])) + sum(heat[t] for t in range(misc["time steps"]))))
    model.Params.TimeLimit = 60
    
    model.setParam('MIPGap',0.01)    
    model.setParam('MIPGapAbs',2)
    model.setParam('Threads',1) 
    model.setParam('OutputFlag',0)
    model.optimize()

    if model.status==gp.GRB.Status.INFEASIBLE:
        model.computeIIS()
        f=open('errorfile.txt','w')
        f.write('\nThe following constraint(s) cannot be satisfied:\n')
        for c in model.getConstrs():
            if c.IISConstr:
                f.write('%s' % c.constrName)
                f.write('\n')
        f.close()
    
    
    res_x = np.array([x[t].X for t in range(misc["time steps"])])
    res_heat = np.array([heat[t].X for t in range(misc["time steps"])])
    res_powerHP = np.array([power[t].X for t in range(misc["time steps"])])
    res_powerHR = np.array([powerHR[t].X for t in range(misc["time steps"])])

    res_temp = np.array([temperature[t].X for t in range(misc["time steps"])])

    return (res_x, res_heat, res_powerHP, res_powerHR, res_temp, model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
