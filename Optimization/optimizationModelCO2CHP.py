# -*- coding: utf-8 -*-
"""
Created on Tue Jan 30 20:04:00 2018

@author: ssi
"""
from __future__ import division

import gurobipy as gp
import numpy as np

def optimize(chp, sto, hou, co2, misc):
    """
    Parameters
    ----------
    chp : dictionary with CHP definitions
        - P_min : float [kW]
        - P_max : float [kW]
        - etael: electrical efficiency [-]
        - etath: thermal efficiency [-]
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
    co2 : array
        co2 intensity signal of electrical power[g/kWh]
    misc : dictionary with miscellaneous data
        - dt : integer - time discretization in seconds
        - time steps : integer - number of time steps
        - CO2gas: CO2 intensity of natural gas when burning it[g/kWh]
    """
    model = gp.Model("HP operation optimization with time-resolved CO2 factors")
    
    x = {} # CHP activation for space heating
    temperature = {} # Storage temperature
    heat = {} # Heat production CHP
    heatBoi={} #HeatProduction boiler
    power = {} # Power production CHP
    Qgas={} #gas consumption of CHP system
    QgasBoi={} #gas consumption of peak load boiler    
    
    for t in range(misc["time steps"]):
        x[t] = model.addVar(vtype="B", name="activation_"+str(t))
        temperature[t] = model.addVar(vtype="C", name="temperature_"+str(t))
        heat[t] = model.addVar(vtype="C", name="heat_"+str(t))
        heatBoi[t] = model.addVar(vtype="C", name="heatBoi_"+str(t))
        power[t] = model.addVar(vtype="C", name="power_"+str(t))
        Qgas[t] = model.addVar(vtype="C", name="Qgas_"+str(t))
        QgasBoi[t] = model.addVar(vtype="C", name="QgasBoi_"+str(t))

           
    model.update()
    
    model.setObjective(sum(((Qgas[t]+QgasBoi[t])*misc["CO2gas"]-(co2[t]+hou["congSignal"][t]) * (power[t])) for t in range(misc["time steps"])),
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
                                     (heat[t]+heatBoi[t] - hou["heat"][t]
                                     -sto["k_sto"]*sto["A_sto"]*(temperature_previous-sto["T_amb_sto"])/1000)),
                        name="storage balance_"+str(t))
    
    for t in range(misc["time steps"]):
        model.addConstr(heat[t] == Qgas[t]*chp["etath"], 
                        name="Coupling gas and heat_"+str(t))
        model.addConstr(Qgas[t] == power[t]/chp["etael"], 
                        name="Coupling gas and heat_"+str(t))
        model.addConstr(QgasBoi[t] == heatBoi[t]/chp["etaBoi"], 
                        name="Coupling gas and heat boiler_"+str(t))          
                    
    for t in range(misc["time steps"]):
        model.addConstr(power[t] >= x[t] * chp["P_min"], name="min power_"+str(t))
        model.addConstr(power[t] <= x[t] * chp["P_max"], name="max power_"+str(t))
        model.addConstr(heatBoi[t] <= heat[t], name="max heat boiler_"+str(t))
        

    model.Params.TimeLimit = 60
    
    model.setParam('MIPGap',0.01)    
    model.setParam('MIPGapAbs',2)
    model.setParam('Threads',1) 
    model.setParam('OutputFlag',0)
    model.optimize()

    if (model.status==gp.GRB.Status.INFEASIBLE)|(model.status==4):
        print("test")
        model.computeIIS()
        f=open('errorfile.txt','w')
        f.write('\nThe following constraint(s) cannot be satisfied:\n')
        for c in model.getConstrs():
            if c.IISConstr:
                f.write('%s' % c.constrName)
                f.write('\n')
                #print(c.constrName)
        f.close()
    
    print(model.status)
    res_x = np.array([x[t].X for t in range(misc["time steps"])])
    res_heat = np.array([heat[t].X for t in range(misc["time steps"])])
    res_power = np.array([power[t].X for t in range(misc["time steps"])])
    res_temp = np.array([temperature[t].X for t in range(misc["time steps"])])
    res_gas = np.array([Qgas[t].X for t in range(misc["time steps"])])+np.array([QgasBoi[t].X for t in range(misc["time steps"])])   
    
    
    return (res_x, res_heat, res_power, res_gas, res_temp, model.ObjVal,model.MIPGap,model.Runtime,model.ObjBound)
