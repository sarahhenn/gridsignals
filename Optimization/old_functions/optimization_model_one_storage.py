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
        - cap : float [kWh] - maximum capacity
        - cap_DHW: float [kWh] - maximum capacity of DHW storage
        - init : float [kWh] - initial storage content
        - init_DHW : float [kWh] - initial storage content of DHW storage
        - loss : float [-] - relative storage losses between two consecutive time steps
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
    
    x_DHW={} # HP activation for DHW production
    energy_DHW={} #Storage content of DHW storage
    heat_DHW = {} # Heat production during DHW production
    power_DHW = {} # Power consumption HP for DHW consumption
    pen_DHW={} # penalty for DHW storage
    pen_DHW_lb={} # penalty for DHW storage
    
    for t in range(misc["time steps"]):
        x_DHW[t] = model.addVar(vtype="B", name="activation_DHW_"+str(t))
        energy_DHW[t]=model.addVar(vtype="C",lb=-10000, name="energy_DHW_"+str(t))
        heat_DHW[t] = model.addVar(vtype="C", name="heat_DHW_"+str(t))
        power_DHW[t]= model.addVar(vtype="C", name="power_DHW_"+str(t))
        pen_DHW[t]=model.addVar(vtype="C", name="pen_DHW_"+str(t))
        pen_DHW_lb[t]=model.addVar(vtype="C", name="pen_DHW_lb_"+str(t))
    model.update()
    

    #included power for space heating and DHW in target fucntion
    #additionally penalties for too high or too low storage contents
    #and a penalty for operation outside of congestion times (can be set to a zero vector)   
    model.setObjective(sum((fpe[t] * (power_DHW[t])+100*(pen_DHW[t]+pen_DHW_lb[t])+hou["congSignal"][t]*(power_DHW[t])) for t in range(misc["time steps"])),
                       gp.GRB.MINIMIZE)    
    for t in range(misc["time steps"]):
        model.addConstr(energy_DHW[t] <= sto["cap_DHW"]+pen_DHW[t], name="max sto cap DHW_"+str(t))
        model.addConstr(energy_DHW[t] >= -pen_DHW_lb[t], name="min sto cap DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        if t == 0:
            energy_DHW_previous = sto["init_DHW"]
        else:
            energy_DHW_previous = energy_DHW[t-1]
            
        model.addConstr(energy_DHW[t] == (1-sto["loss_var_DHW"]) * energy_DHW_previous + 
                                     misc["dt"] * (heat_DHW[t] - hou["DHW"][t]-sto["loss_const_DHW"][t]),
                        name="storage balance DHW_"+str(t))

    
    for t in range(misc["time steps"]):
        model.addConstr(heat_DHW[t] == hp["cop_DHW"][t] * power_DHW[t], 
                        name="Coupling heat and power DHW_"+str(t))
    
    for t in range(misc["time steps"]):
        model.addConstr(power_DHW[t] >= x_DHW[t] * hp["P_min_DHW"][t], name="min power DHW_"+str(t))
        model.addConstr(power_DHW[t] <= x_DHW[t] * hp["P_max_DHW"][t], name="max power DHW_"+str(t))

    
        
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
    
    res_energy_DHW = np.array([energy_DHW[t].X for t in range(misc["time steps"])])
    res_power_DHW = np.array([power_DHW[t].X for t in range(misc["time steps"])])    
    res_x = np.zeros(np.size(res_energy_DHW))
    res_heat = np.zeros(np.size(res_energy_DHW))
    res_heat_DHW=np.array([heat_DHW[t].X for t in range(misc["time steps"])])
    res_power = np.zeros(np.size(res_energy_DHW))
    res_energy = np.zeros(np.size(res_energy_DHW))


    #unnecessary, will be removed soon
    res_power_HR=np.zeros(np.size(res_x))
    res_power_HR_DHW=np.zeros(np.size(res_x))
    return (res_x, res_heat,res_heat_DHW, res_power,res_power_DHW,res_power_HR,res_power_HR_DHW, res_energy, res_energy_DHW,model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
