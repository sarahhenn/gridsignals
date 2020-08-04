# -*- coding: utf-8 -*-
"""
Created on Thu Apr 07 15:06:43 2016

@author: tsz
"""
from __future__ import division

import gurobipy as gp
import numpy as np

def optimize(ev, hou, co2, misc):
    """
    Parameters
    ----------
    ev : dictionary with electric vehicle definitions
        - P_min : float [kW]
        - P_max : float [kW]
        - SOC_min: float [-] minimum state of charge
        - SOC_max: float [-] maximum state of charge
        - etaCh: charging efficiency [-]
        - etaDis: discharging efficiency [-]
        - energyContent: maximum energy content of storage [kWh]
        - withFeedIn: can the EV feed electricity back to the grid [bool]
        - init: initial SOC [-]
    hou : dictionary with house inputs
        - EV_cons : array with electricity consumption over time [kW]
        => is always set to the time stamp when the car leaves the building
        - availability: array with availability of electric vehicle in this building [-]
        - congSignal: derived congestion signal for consideration of congestion mitigation [-]
    co2 : array
        array of co2 emission coefficients
    misc : dictionary with miscellaneous data
        - dt : integer - time discretization in seconds
        - time steps : integer - number of time steps
    """
    model = gp.Model("HP operation optimization with time-resolved CO2 factors")
    
    x = {} # HP activation for space heating
    SOC = {} # Storage temperature
    power = {} # Power consumption EV
    if ev["withFeedIn"]:
        powerFeed={}
    for t in range(misc["time steps"]):
        x[t] = model.addVar(vtype="B", name="activation_charge_"+str(t))
        SOC[t] = model.addVar(vtype="C", name="SOC_"+str(t))
        power[t] = model.addVar(vtype="C", name="power_"+str(t))
        if ev["withFeedIn"]:
            powerFeed[t] = model.addVar(vtype="C", name="powerFeed_"+str(t))
           
    model.update()
    if ev["withFeedIn"]:
         model.setObjective(sum((co2[t]+hou["congSignal"][t]) * (power[t]-powerFeed[t]) for t in range(misc["time steps"])),
                               gp.GRB.MINIMIZE)   

    else:
        model.setObjective(sum(((co2[t]+hou["congSignal"][t]) * (power[t])) for t in range(misc["time steps"])),
                               gp.GRB.MINIMIZE)
                           
    for t in range(misc["time steps"]):
        model.addConstr(SOC[t] <= ev["SOCmax"], name="max sto cap_"+str(t))
        model.addConstr(SOC[t] >= ev["SOCmin"], name="min sto cap_"+str(t))


            
    for t in range(misc["time steps"]):
        if t == 0:
            SOC_previous = ev["init"]

        else:
            SOC_previous = SOC[t-1]
        
        if ev["withFeedIn"]:
            model.addConstr(SOC[t] == (SOC_previous +
                                        (misc["dt"] * (power[t] * ev["etaCh"] - powerFeed[t]/ev["etaDis"]) - hou["EVcons"][t]/ev["etaDis"]) / ev["energyContent"] - ev["selfDis"]*misc["dt"]*SOC_previous) , 
                                        name="storage balance_"+str(t))        
        else:
            model.addConstr(SOC[t] == (SOC_previous +
                                        (misc["dt"] * power[t] * ev["etaCh"]- hou["EVcons"][t]) / ev["energyContent"] - ev["selfDis"]*misc["dt"]*SOC_previous), 
                                        name="storage balance_"+str(t))
                    
    for t in range(misc["time steps"]):
        model.addConstr(power[t] >= x[t] * ev["Pmin"], name="min power_"+str(t))
        model.addConstr(power[t] <= x[t] * ev["Pmax"], name="max power_"+str(t))
        if ev["withFeedIn"]:
            model.addConstr(powerFeed[t] >= x[t] * ev["Pmin"], name="min power_"+str(t))
            model.addConstr(powerFeed[t] <= x[t] * ev["Pmax"], name="max power_"+str(t))
    for t in range(misc["time steps"]):
        model.addConstr(x[t] <= hou["availability"][t], name="availability_"+str(t))

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
    res_power = np.array([power[t].X for t in range(misc["time steps"])])
    res_power_feed = np.array([powerFeed[t].X for t in range(misc["time steps"])])
    res_soc = np.array([SOC[t].X for t in range(misc["time steps"])])
    return (res_x, res_power-res_power_feed,res_soc, model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
