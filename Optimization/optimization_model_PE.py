# -*- coding: utf-8 -*-
"""
Created on Thu Apr 07 15:06:43 2016

@author: tsz
"""
from __future__ import division

import gurobipy as gp
import numpy as np

def optimize(hp, sto, hou, fpe, misc):
    """
    Parameters
    ----------
    hp : dictionary with heat pump definitions
        - cop : array of float [-]
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
        - extraDHW: boolean - if true, an extra storage for DHW is implemented
    """
#    print("Das ist Test 1!")
    model = gp.Model("HP operation optimization with dynamic primary energy factors")
#    print("Das ist Test 2!")    
    
    x = {} # HP activation for space heating
    temperature = {} # Storage temperature
    heat = {} # Heat production HP
    power = {} # Power consumption HP
    if misc["extraDHW"]:
            x_DHW = {} # HP activation for space heating
            temperature_DHW = {} # Storage temperature
            heat_DHW = {} # Heat production HP
            power_DHW = {} # Power consumption HP
    for t in range(misc["time steps"]):
        x[t] = model.addVar(vtype="B", name="activation_"+str(t))
        temperature[t] = model.addVar(vtype="C", name="temperature_"+str(t))
        heat[t] = model.addVar(vtype="C", name="heat_"+str(t))
        power[t] = model.addVar(vtype="C", name="power_"+str(t))
        if misc["extraDHW"]:
            x_DHW[t] = model.addVar(vtype="B", name="activation_DHW_"+str(t))
            temperature_DHW[t] = model.addVar(vtype="C", name="temperature_DHW_"+str(t))
            heat_DHW[t] = model.addVar(vtype="C", name="heat_DHW_"+str(t))
            power_DHW[t] = model.addVar(vtype="C", name="power_DHW_"+str(t))            
    model.update()
    
#    model.setObjective(sum(fpe[t] * (power[t]+power_DHW[t])+0.1*(power[t]+power_DHW[t]) for t in range(misc["time steps"])),
#                       gp.GRB.MINIMIZE)
    if misc["extraDHW"]:
        model.setObjective(sum(((fpe[t]+hou["congSignal"][t]) * (power[t]+power_DHW[t])) for t in range(misc["time steps"])),
                           gp.GRB.MINIMIZE)
    else:
        model.setObjective(sum(((fpe[t]+hou["congSignal"][t]) * (power[t])) for t in range(misc["time steps"])),
                           gp.GRB.MINIMIZE)    
    for t in range(misc["time steps"]):
        model.addConstr(temperature[t] <= sto["T_max"][t], name="max sto cap_"+str(t))
        model.addConstr(temperature[t] >= sto["T_min"][t], name="min sto cap_"+str(t))
        if misc["extraDHW"]:
            model.addConstr(temperature_DHW[t] <= sto["T_max_DHW"][t], name="max sto cap_DHW_"+str(t))
            model.addConstr(temperature_DHW[t] >= sto["T_min_DHW"][t], name="min sto cap_DHW_"+str(t))

            
    for t in range(misc["time steps"]):
        if t == 0:
            temperature_previous = sto["init"]
            if misc["extraDHW"]:
                temperature_previous_DHW = sto["init_DHW"]    
        else:
            temperature_previous = temperature[t-1]
            if misc["extraDHW"]:
                temperature_previous_DHW = temperature_DHW[t-1]
                
        model.addConstr(temperature[t] == (temperature_previous + 
                                     misc["dt"] * sto["conv_kWh_2_K"] *
                                     (heat[t] - hou["heat"][t]
                                     -sto["k_sto"]*sto["A_sto"]*(temperature_previous-sto["T_amb_sto"])/1000)),
                        name="storage balance_"+str(t))
        if misc["extraDHW"]:                
            model.addConstr(temperature_DHW[t] == (temperature_previous_DHW + 
                                         misc["dt"] * sto["conv_kWh_2_K_DHW"] *
                                         (heat_DHW[t] - hou["heat_DHW"][t]
                                         -sto["k_sto_DHW"]*sto["A_sto_DHW"]*(temperature_previous_DHW-sto["T_amb_sto"])/1000)),
                            name="storage balance_DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        model.addConstr(heat[t] == hp["cop"][t] * power[t], 
                        name="Coupling heat and power_"+str(t))
        if misc["extraDHW"]:
                model.addConstr(heat_DHW[t] == hp["cop_DHW"][t] * power_DHW[t], 
                    name="Coupling heat and power_DHW_"+str(t))
                    
    for t in range(misc["time steps"]):
        model.addConstr(power[t] >= x[t] * hp["P_min"][t], name="min power_"+str(t))
        model.addConstr(power[t] <= x[t] * hp["P_max"][t], name="max power_"+str(t))
        if misc["extraDHW"]:
            model.addConstr(power_DHW[t] >= x_DHW[t] * hp["P_min_DHW"][t], name="min power_DHW_"+str(t))
            model.addConstr(power_DHW[t] <= x_DHW[t] * hp["P_max_DHW"][t], name="max power_DHW_"+str(t))    
    

    if misc["extraDHW"]:
            for t in range(misc["time steps"]):
                model.addConstr(x[t] +x_DHW[t]<=1, name="operation_"+str(t))
    model.Params.TimeLimit = 60
    
    #inserted newly
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
    res_power = np.array([power[t].X for t in range(misc["time steps"])])
    res_temp = np.array([temperature[t].X for t in range(misc["time steps"])])
    if misc["extraDHW"]:
        res_heat_DHW=np.array([heat_DHW[t].X for t in range(misc["time steps"])])
        res_power_DHW=np.array([power_DHW[t].X for t in range(misc["time steps"])])
        res_temp_DHW=np.array([temperature_DHW[t].X for t in range(misc["time steps"])])
    else:
        res_heat_DHW=np.zeros(np.size(res_heat))
        res_power_DHW=np.zeros(np.size(res_power))
        res_temp_DHW=np.zeros(np.size(res_temp))
#    (x_dyn, heat_dyn,heat_DHW, power_dyn,power_DHW, T_sto,T_sto_DHW, objVal,MIPGap,Runtime,ObjBound)
    return (res_x, res_heat,res_heat_DHW, res_power,res_power_DHW, res_temp,res_temp_DHW, model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
