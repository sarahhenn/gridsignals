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
        - cop_DHW: array of float [-]
        - P_min : array of float [kW]
        - P_max : array of float [kW]
        - P_min_DHW: : array of float [kW]
        - P_max_DHW: : array of float [kW] 
        - P_max_HR: array of float [kW] 
    sto : dictionary with storage definitions
        - T_min: array of float [°C] - minimum allowed storage temperature
        - T_max: array of float [°C] - maximum allowed storage temperature
        - T_min_DHW: array of float [°C] - minimum allowed storage temperature for DHW
        - T_max_DHW: array of float [°C] - maximum allowed storage temperature for DHW
        - init : float [°C] - initial storage temperature
        - init_DHW : float [°C] - initial storage temperature of DHW storage
        - conv_kWh_2_K: float [K/kWh] - conversion factor to calculate temperature difference resulting from energy
        - conv_kWh_2_K_DHW: float [K/kWh] - conversion factor to calculate temperature difference resulting from energy
        - k_sto : float [-] - storage losses
        - A_sto: float [m²] - surrounding surface of storage
        - T_amb_sto [°C] - surrounding temperature of storages
        - k_sto_DHW : float [-] - storage losses for DHW storage
        - A_sto_DHW: float [m²] - surrounding surface of storage
    hou : dictionary with house inputs
        - heat : array heat demand in kW
        - heat_DHW: array DHW heat demand in kW
    fpe : array
        Primary energy coefficients
    misc : dictionary with miscellaneous data
        - dt : integer - time discretization in seconds
        - time steps : integer - number of time steps
    """

    model = gp.Model("HP operation optimization with dynamic primary energy factors")
    
    x = {} # HP activation for space heating
    x_DHW={} # HP activation for DHW production
    T = {} # Storage energy content
    T_DHW={} #Storage content of DHW storage
    heat = {} # Heat production HP
    heat_DHW = {} # Heat production during DHW production
    power = {} # Power consumption HP
    power_DHW = {} # Power consumption HP for DHW consumption
    pen_SH={} # penalty for space heating storage
    pen_DHW={} # penalty for DHW storage
    pen_SH_lb={} # penalty for space heating storage
    pen_DHW_lb={} # penalty for DHW storage
    
    for t in range(misc["time steps"]):
        x[t] = model.addVar(vtype="B", name="activation_"+str(t))
        x_DHW[t] = model.addVar(vtype="B", name="activation_DHW_"+str(t))
        T[t] = model.addVar(vtype="C",lb=0, name="T_"+str(t))
        T_DHW[t]=model.addVar(vtype="C",lb=0, name="T_DHW_"+str(t))
        heat[t] = model.addVar(vtype="C", name="heat_"+str(t))
        heat_DHW[t] = model.addVar(vtype="C", name="heat_DHW_"+str(t))
        power[t] = model.addVar(vtype="C", name="power_"+str(t))
        power_DHW[t]= model.addVar(vtype="C", name="power_DHW_"+str(t))
        pen_SH[t]=model.addVar(vtype="C", name="pen_SH_"+str(t))
        pen_DHW[t]=model.addVar(vtype="C", name="pen_DHW_"+str(t))
        pen_SH_lb[t]=model.addVar(vtype="C", name="pen_SH_lb_"+str(t))
        pen_DHW_lb[t]=model.addVar(vtype="C", name="pen_DHW_lb_"+str(t))
    model.update()
    

    #included power for space heating and DHW in target fucntion
    #additionally penalties for too high or too low storage temperatures
    #and a penalty for operation outside of congestion times (can be set to a zero vector)   
    model.setObjective(sum((fpe[t] * (power[t]+power_DHW[t])+1000*(pen_SH[t]+pen_DHW[t]+pen_SH_lb[t]+pen_DHW_lb[t])+hou["congSignal"][t]*(power[t]+power_DHW[t])) for t in range(misc["time steps"])),
                       gp.GRB.MINIMIZE)    
    for t in range(misc["time steps"]):
        model.addConstr(T[t] <= sto["T_max"][t]+pen_SH[t], name="max sto cap_"+str(t))
        model.addConstr(T_DHW[t] <= sto["T_max_DHW"][t]+pen_DHW[t], name="max sto cap DHW_"+str(t))
        model.addConstr(T[t] >= sto["T_min"][t]-pen_SH_lb[t], name="min sto cap_"+str(t))
        model.addConstr(T_DHW[t] >= sto["T_min_DHW"][t]-pen_DHW_lb[t], name="min sto cap DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        if t == 0:
            T_previous = sto["init"]
            T_DHW_previous = sto["init_DHW"]
        else:
            T_previous = T[t-1]
            T_DHW_previous = T_DHW[t-1]
            
#        model.addConstr(energy[t] == (1-sto["loss_var"]*misc["dt"]) * energy_previous + 
#                                     misc["dt"] * (heat[t] - hou["heat"][t]-sto["loss_const"][t]),
#                        name="storage balance_"+str(t))

        model.addConstr(T[t] == (T_previous + 
                                     sto["conv_kWh_2_K"] * 
                                     misc["dt"] *(heat[t] - hou["heat"][t]
                                     -sto["k_sto"]*sto["A_sto"]*(T_previous-sto["T_amb_sto"])/1000)),
                        name="storage balance_"+str(t))

        model.addConstr(T_DHW[t] == (T_DHW_previous + 
                                     sto["conv_kWh_2_K_DHW"] *
                                     misc["dt"] *(heat_DHW[t] - hou["DHW"][t]
                                     -sto["k_sto_DHW"]*sto["A_sto_DHW"]*(T_previous-sto["T_amb_sto"])/1000)),
                        name="storage balance DHW_"+str(t))


#        model.addConstr(energy_DHW[t] == (1-sto["loss_var_DHW"]) * energy_DHW_previous + 
#                                     misc["dt"] * (heat_DHW[t] - hou["DHW"][t]-sto["loss_const_DHW"][t]),
#                        name="storage balance DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        model.addConstr(heat[t] == hp["cop"][t] * power[t], 
                        name="Coupling heat and power_"+str(t))
        model.addConstr(heat_DHW[t] == hp["cop_DHW"][t] * power_DHW[t], 
                        name="Coupling heat and power DHW_"+str(t))
    
    for t in range(misc["time steps"]):
        model.addConstr(power[t] >= x[t] * hp["P_min"][t], name="min power_"+str(t))
        model.addConstr(power[t] <= x[t] * hp["P_max"][t], name="max power_"+str(t))
        model.addConstr(power_DHW[t] >= x_DHW[t] * hp["P_min_DHW"][t], name="min power DHW_"+str(t))
        model.addConstr(power_DHW[t] <= x_DHW[t] * hp["P_max_DHW"][t], name="max power DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        model.addConstr(x[t] +x_DHW[t]<=1, name="operation_"+str(t))
        
    model.Params.TimeLimit = 10
    
    #inserted newly
    model.setParam('MIPFocus',3)
    model.setParam('MIPGap',0.01)    
    model.setParam('MIPGapAbs',1)
    model.setParam('Threads',6)    
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
    res_heat_DHW=np.array([heat_DHW[t].X for t in range(misc["time steps"])])
    res_power = np.array([power[t].X for t in range(misc["time steps"])])
    res_power_DHW = np.array([power_DHW[t].X for t in range(misc["time steps"])])
    res_temp = np.array([T[t].X for t in range(misc["time steps"])])
    res_temp_DHW = np.array([T_DHW[t].X for t in range(misc["time steps"])])

    return (res_x, res_heat,res_heat_DHW, res_power,res_power_DHW, res_temp, res_temp_DHW,model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
