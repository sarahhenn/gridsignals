within OFD_Calculations;
model MultizoneEquipped
  "Multizone model with ideal heater and cooler and AHU"
  extends
    AixLib.ThermalZones.ReducedOrder.Multizone.BaseClasses.PartialMultizone;

  parameter Boolean heatAHU
    "Status of heating of AHU"
    annotation (Dialog(tab="AirHandlingUnit", group="AHU Modes"));
  parameter Boolean coolAHU
    "Status of cooling of AHU"
    annotation (Dialog(tab="AirHandlingUnit", group="AHU Modes"));
  parameter Boolean dehuAHU=if heatAHU and coolAHU then true
       else false
    "Status of dehumidification of AHU (Cooling and Heating must be enabled)"
    annotation (Dialog(tab="AirHandlingUnit", group="AHU Modes"));
  parameter Boolean huAHU=if heatAHU and coolAHU then true
       else false
    "Status of humidification of AHU (Cooling and Heating must be enabled)"
    annotation (Dialog(tab="AirHandlingUnit", group="AHU Modes"));
  parameter Real BPFDehuAHU(
    min=0,
    max=1)
    "By-pass factor of cooling coil during dehumidification"
    annotation (Dialog(tab="AirHandlingUnit", group="Settings AHU Value"));
  parameter Boolean HRS=true
    "Status of Heat Recovery System of AHU"
    annotation (
    Dialog(tab="AirHandlingUnit", group="AHU Modes"), choices(checkBox=true));
  parameter Real effHRSAHU_enabled(
    min=0,
    max=1)
    "Efficiency of HRS when enabled"
    annotation (Dialog(
    tab="AirHandlingUnit",
    group="Settings AHU Value",
    enable=HRS));
  parameter Real effHRSAHU_disabled(
    min=0,
    max=1)
    "Efficiency of HRS when disabled"
    annotation (Dialog(
    tab="AirHandlingUnit",
    group="Settings AHU Value",
    enable=HRS));
  parameter Modelica.SIunits.Time sampleRateAHU(min=0) = 1800
    "Time period for sampling"
    annotation (Dialog(tab="AirHandlingUnit", group="Settings for State Machines"));
  parameter Modelica.SIunits.Pressure dpAHU_sup
    "Pressure difference over supply fan"
    annotation (Dialog(tab="AirHandlingUnit", group="Fans"));
  parameter Modelica.SIunits.Pressure dpAHU_eta
    "Pressure difference over extract fan"
    annotation (Dialog(tab="AirHandlingUnit", group="Fans"));
  parameter Modelica.SIunits.Efficiency effFanAHU_sup
    "Efficiency of supply fan"
    annotation (Dialog(tab="AirHandlingUnit", group="Fans"));
  parameter Modelica.SIunits.Efficiency effFanAHU_eta
    "Efficiency of extract fan"
    annotation (Dialog(tab="AirHandlingUnit", group="Fans"));
  replaceable model AHUMod =
    AixLib.Airflow.AirHandlingUnit.AHU
    constrainedby AixLib.Airflow.AirHandlingUnit.BaseClasses.PartialAHU
    "Air handling unit model"
    annotation(Dialog(tab="AirHandlingUnit"),choicesAllMatching=true);
  Modelica.Blocks.Interfaces.RealInput ventRate[1] "Input for AHU Conditions [1]: Desired Air Temperature in K [2]: Desired
    minimal relative humidity [3]: Desired maximal relative humidity [4]:
    Schedule Desired Ventilation Flow" annotation (Placement(transformation(
        extent={{20,20},{-20,-20}},
        rotation=180,
        origin={-106,18}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-90,0})));
  Modelica.Blocks.Interfaces.RealInput TSetHeat[numZones](
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC",
    min=0)
    "Set point for heater"
    annotation (Placement(transformation(
    extent={{20,-20},{-20,20}},
    rotation=270,
    origin={-46,-100}), iconTransformation(
    extent={{10,-10},{-10,10}},
    rotation=270,
    origin={-52,-110})));
  Modelica.Blocks.Interfaces.RealInput TSetCool[numZones](
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC",
    min=0)
    "Set point for cooler"
    annotation (Placement(transformation(
    extent={{20,-20},{-20,20}},
    rotation=270,
    origin={-86,-100}), iconTransformation(
    extent={{10,-10},{-10,10}},
    rotation=270,
    origin={-74,-110})));
  Modelica.Blocks.Interfaces.RealOutput PHeater[numZones](final
    quantity="HeatFlowRate", final unit="W") if ASurTot > 0 or VAir > 0
    "Power for heating"
    annotation (
    Placement(transformation(extent={{100,-54},{120,-34}}),
    iconTransformation(extent={{80,-80},{100,-60}})));
  Modelica.Blocks.Interfaces.RealOutput PCooler[numZones](final
    quantity="HeatFlowRate", final unit="W") if ASurTot > 0 or VAir > 0
    "Power for cooling"
    annotation (
    Placement(transformation(extent={{100,-68},{120,-48}}),iconTransformation(
    extent={{80,-100},{100,-80}})));
  AixLib.Utilities.Sources.HeaterCooler.HeaterCoolerPI heaterCooler[numZones](
    final zoneParam=zoneParam,
    each recOrSep=true,
    each staOrDyn=true) if ASurTot > 0 or VAir > 0
    "Heater Cooler with PI control"
    annotation (Placement(transformation(extent={{-48,-70},{-22,-44}})));

protected
  parameter Real zoneFactor[numZones,1](fixed=false)
    "Calculated zone factors";
  parameter Real VAirRes(fixed=false)
    "Resulting air volume in zones supplied by the AHU";

public
  AixLib.BoundaryConditions.WeatherData.Bus weaBus1
    "Weather data bus"
    annotation (Placement(transformation(extent={{-40,40},{-20,60}})));
initial algorithm
  for i in 1:numZones loop
    if zoneParam[i].withAHU then
      VAirRes :=VAirRes + zoneParam[i].VAir;
    end if;
  end for;
  for i in 1:numZones loop
    if zoneParam[i].withAHU then
      if VAirRes > 0 then
        zoneFactor[i,1] :=zoneParam[i].VAir/VAirRes;
      else
        zoneFactor[i,1] :=0;
      end if;
    else
      zoneFactor[i,1] :=0;
    end if;
  end for;

equation
  for i in 1:numZones loop
  end for;

  connect(TSetCool, heaterCooler.setPointCool) annotation (Line(points={{-86,-100},
          {-86,-72},{-48,-72},{-38.12,-72},{-38.12,-66.36}}, color={0,0,127}));
  connect(TSetHeat, heaterCooler.setPointHeat) annotation (Line(points={{-46,-100},
          {-46,-100},{-46,-74},{-32.14,-74},{-32.14,-66.36}}, color={0,0,127}));
  connect(heaterCooler.heatingPower, PHeater) annotation (Line(points={{-22,
          -51.8},{38,-51.8},{92,-51.8},{92,-50},{92,-44},{110,-44}},
                                                              color={0,0,127}));
  connect(heaterCooler.coolingPower, PCooler) annotation (Line(points={{-22,
          -57.78},{12,-57.78},{12,-58},{92,-58},{110,-58}},  color={0,0,127}));
  connect(heaterCooler.heatCoolRoom, zone.intGainsConv) annotation (Line(points={{-23.3,
          -62.2},{86,-62.2},{86,59.25},{80,59.25}},        color={191,0,0}));
  connect(zone.ventRate, ventRate) annotation (Line(points={{44.3,52.28},{44.3,18},
          {30,18},{-106,18}}, color={0,0,127}));
  connect(weaBus, weaBus1) annotation (Line(
      points={{-100,69},{-46,69},{-46,50},{-30,50}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus1.TDryBul, zone[1].ventTemp) annotation (Line(
      points={{-30,50},{2,50},{2,61.505},{35.27,61.505}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}),
            graphics={
        Rectangle(
          extent={{-80,-46},{-2,-70}},
          lineColor={0,0,255},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-80,-50},{-56,-56}},
          lineColor={0,0,255},
          fillColor={212,221,253},
          fillPattern=FillPattern.Solid,
          textString="Heating
Cooling")}),
    Documentation(revisions="<html>
<ul>
  <li>
  September 27, 2016, by Moritz Lauster:<br/>
  Reimplementation based on Annex60 and AixLib models.
  </li>
  <li>
  February 26, 2016, by Moritz Lauster:<br/>
  Fixed bug in share of
  AHU volume flow.
  </li>
  <li>
  April 25, 2015, by Ole Odendahl:<br/>
  Implemented.
  </li>
</ul>
</html>", info="<html>
<p>This is a ready-to-use multizone model with a variable number of thermal zones. It adds heater/cooler devices and an air handling unit to <a href=\"AixLib.ThermalZones.ReducedOrder.Multizone.Multizone\">AixLib.ThermalZones.ReducedOrder.Multizone.Multizone</a>. It defines connectors and a replaceable vector of <a href=\"AixLib.ThermalZones.ReducedOrder.ThermalZone\">AixLib.ThermalZones.ReducedOrder.ThermalZone</a> models. Most connectors are conditional to allow conditional modifications according to parameters or to pass-through conditional removements in <a href=\"AixLib.ThermalZones.ReducedOrder.ThermalZone\">AixLib.ThermalZones.ReducedOrder.ThermalZone</a> and subsequently in <a href=\"AixLib.ThermalZones.ReducedOrder.RC.FourElements\">AixLib.ThermalZones.ReducedOrder.RC.FourElements</a>.</p>
<h4>Typical use and important parameters</h4>
<p>The model needs parameters describing general properties of the building (indoor air volume, net floor area, overall surface area) and a vector with length of number of zones containing <a href=\"AixLib.DataBase.ThermalZones.ZoneBaseRecord\">AixLib.DataBase.ThermalZones.ZoneBaseRecord</a> records to define zone properties and heater/cooler properties. An additional tab allows configuring the air handling unit. The air handling unit facilitates heating, cooling, humidification, dehumidification and heat recovery modes. The user can redeclare the thermal zone model choosing from <a href=\"AixLib.ThermalZones.ReducedOrder.ThermalZone\">AixLib.ThermalZones.ReducedOrder.ThermalZone</a>. Further parameters for medium, initialization and dynamics originate from <a href=\"AixLib.Fluid.Interfaces.LumpedVolumeDeclarations\">AixLib.Fluid.Interfaces.LumpedVolumeDeclarations</a>. A typical use case is a simulation of a multizone building for district simulations. The multizone model calculates heat load and indoor air profiles. </p>
<h4>References</h4>
<p>For automatic generation of thermal zone and multizone models as well as for datasets, see <a href=\"https://github.com/RWTH-EBC/TEASER\">https://github.com/RWTH-EBC/TEASER</a></p>
<ul>
<li>German Association of Engineers: Guideline VDI 6007-1, March 2012: Calculation of transient thermal response of rooms and buildings - Modelling of rooms. </li>
<li>Lauster, M.; Teichmann, J.; Fuchs, M.; Streblow, R.; Mueller, D. (2014): Low order thermal network models for dynamic simulations of buildings on city district scale. In: Building and Environment 73, p. 223&ndash;231. DOI: <a href=\"http://dx.doi.org/10.1016/j.buildenv.2013.12.016\">10.1016/j.buildenv.2013.12.016</a>. </li>
</ul>
<h4>Examples</h4>
<p>See <a href=\"AixLib.ThermalZones.ReducedOrder.Examples.Multizone\">AixLib.ThermalZones.ReducedOrder.Examples.Multizone</a>.</p>
</html>"));
end MultizoneEquipped;
