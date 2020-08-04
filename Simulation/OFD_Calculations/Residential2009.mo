within OFD_Calculations;
model Residential2009
  "This is the simulation model of Residential2009 with traceable ID 0"

  MultizoneEquipped                                            multizone(
    redeclare package Medium = Modelica.Media.Air.SimpleAir,
    buildingID=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    VAir = 350.0,
    ABuilding=140.0,
    ASurTot=789.8666666666668,
    numZones = 1,
  zone(ROM(extWallRC(thermCapExt(each der_T(fixed=true))),
           intWallRC(thermCapInt(each der_T(fixed=true))),floorRC(
            thermCapExt(each der_T(fixed=true))),roofRC(thermCapExt(each
           der_T(fixed=true))))),
   redeclare model corG =
        AixLib.ThermalZones.ReducedOrder.SolarGain.CorrectionGDoublePane,
    BPFDehuAHU=1,
    effHRSAHU_enabled=1,
    effHRSAHU_disabled=1,
    effFanAHU_sup=1,
    effFanAHU_eta=1,
    heatAHU=false,
    coolAHU=false,
    redeclare model thermalZone =
        AixLib.ThermalZones.ReducedOrder.ThermalZone.ThermalZone,
    T_start=293.15,
    zoneParam={Residential2009_DataBase.Residential2009_SingleDwelling()},
    dpAHU_sup=100000,
    dpAHU_eta=100000)
    "Multizone"
    annotation (Placement(transformation(extent={{32,-8},{82,56}})));

  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    calTSky=AixLib.BoundaryConditions.Types.SkyTemperatureCalculation.HorizontalRadiation,
    computeWetBulbTemperature=false,
    filNam="D:/Input/TRY2010_05_Jahr.mos")
    "Weather data reader"
    annotation (Placement(transformation(extent={{-82,30},{-62,50}})));

  Modelica.Blocks.Continuous.Integrator integrator(k=1/3600/1000)
    annotation (Placement(transformation(extent={{102,-8},{122,12}})));
  Modelica.Blocks.Interfaces.RealOutput QHeat "Connector of Real output signal"
    annotation (Placement(transformation(extent={{130,-10},{150,10}})));
  Modelica.Blocks.Sources.Constant Tset[1](each k=293.15)
    "Set point for cooler"
    annotation (Placement(transformation(extent={{82,-60},{66,-44}})));
  Modelica.Blocks.Sources.Constant const3[1](each k=5000)
    "Set point for cooler" annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=0,
        origin={54,-62})));
  Modelica.Blocks.Interfaces.RealOutput dotQHeat "Power for heating"
    annotation (Placement(transformation(extent={{132,20},{152,40}})));
  Modelica.Blocks.Interfaces.RealOutput TRoom "Indoor air temperature"
    annotation (Placement(transformation(extent={{134,60},{154,80}})));
  Modelica.Blocks.Interfaces.RealOutput dotQHeatInput "Power for heating"
    annotation (Placement(transformation(extent={{132,38},{152,58}})));
  AixLib.BoundaryConditions.WeatherData.Bus weaBus1
             "Weather data bus"
    annotation (Placement(transformation(extent={{-36,38},{-16,58}})));
  Modelica.Blocks.Interfaces.RealOutput TAmb "Outdoor air temperature"
    annotation (Placement(transformation(extent={{134,80},{154,100}})));
  Modelica.Blocks.Interfaces.RealOutput airExchangeRate
    "Connector of Real output signal"
    annotation (Placement(transformation(extent={{-16,-6},{4,14}})));
  AixLib.Building.Components.DryAir.VarAirExchange
                                            airExc(final V=multizone.zoneParam[1].VAir)
    "Heat flow due to ventilation"
    annotation (Placement(transformation(extent={{-12,-16},{4,0}})));
protected
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature preTemVen
    "Prescribed temperature for ventilation"
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-34,-4})));
public
  Modelica.Blocks.Sources.Constant Tset2[1](
                                           each k=0) "Set point for cooler"
    annotation (Placement(transformation(extent={{8,-8},{-8,8}},
        rotation=180,
        origin={8,24})));
  Modelica.Blocks.Sources.Constant nairInfilt[1](each k=0.2)
    "Air exchange rate infiltration" annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={-92,8})));
  Modelica.Blocks.Interfaces.RealOutput dotQIG
    "Connector of Real output signal"
    annotation (Placement(transformation(extent={{132,-100},{152,-80}})));
  Modelica.Blocks.Sources.CombiTimeTable occupancyTable(
    tableOnFile=true,
    tableName="occupancy",
    fileName="D:/Ergebnisse/Optimization_Evaluation/Simulation/InputData/occupancy_1.mat",
    columns={2,3,4})
    "Table includes relative occupancy, air exchange rate and internal gains by appliances"
    annotation (Placement(transformation(extent={{-130,-96},{-110,-76}})));
  Modelica.Blocks.Sources.Constant blind[2](each k=0)
    "Set point for cooler"
    annotation (Placement(transformation(extent={{102,-36},{86,-20}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-56,-22},{-42,-8}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow radiativeIntGains
    annotation (Placement(transformation(extent={{2,-34},{14,-22}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow convectiveIntGains
    annotation (Placement(transformation(extent={{2,-48},{14,-36}})));
  Modelica.Blocks.Math.Gain gain(k=shareConv)
    annotation (Placement(transformation(extent={{-14,-48},{-4,-38}})));
  Modelica.Blocks.Math.Gain gain1(k=1 - shareConv)
    annotation (Placement(transformation(extent={{-14,-34},{-4,-24}})));
    parameter Real shareConv=0.5;
equation
  dotQIG=multizone.zone[1].humanSenHea.ConvHeat.Q_flow;
  connect(weaDat.weaBus, multizone.weaBus) annotation (Line(
      points={{-62,40},{-30,40},{-30,36.8},{37,36.8}},
      color={255,204,51},
      thickness=0.5));

  connect(integrator.y, QHeat)
    annotation (Line(points={{123,2},{132,0},{140,0}}, color={0,0,127}));
  connect(QHeat, QHeat)
    annotation (Line(points={{140,0},{136,0},{140,0}}, color={0,0,127}));
  connect(multizone.TSetHeat, Tset.y) annotation (Line(points={{44,-11.2},{44,-11.2},
          {44,-52},{65.2,-52}}, color={0,0,127}));
  connect(const3.y, multizone.TSetCool) annotation (Line(points={{45.2,-62},{38,
          -62},{38,-11.2},{38.5,-11.2}}, color={0,0,127}));
  connect(multizone.PHeater[1], integrator.u) annotation (Line(points={{79.5,1.6},
          {88.75,1.6},{88.75,2},{100,2}}, color={0,0,127}));
  connect(multizone.PHeater[1], dotQHeat) annotation (Line(points={{79.5,1.6},{100,
          1.6},{100,30},{142,30}}, color={0,0,127}));
  connect(multizone.TAir[1], TRoom) annotation (Line(points={{79.5,36.32},{106,36.32},
          {106,70},{144,70}}, color={0,0,127}));
  connect(dotQHeat, dotQHeatInput) annotation (Line(points={{142,30},{140,30},{140,
          48},{142,48}}, color={0,0,127}));
  connect(weaDat.weaBus, weaBus1) annotation (Line(
      points={{-62,40},{-46,40},{-46,48},{-26,48}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TAmb, weaBus1.TDryBul) annotation (Line(points={{144,90},{-12,90},{-12,
          48},{-26,48}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(airExc.port_b, multizone.intGainsConv[1]) annotation (Line(points={{4,
          -8},{20,-8},{20,1.6},{37,1.6}}, color={191,0,0}));
  connect(preTemVen.port, airExc.port_a) annotation (Line(points={{-28,-4},{-22,
          -4},{-22,-8},{-12,-8}}, color={191,0,0}));
  connect(weaBus1.TDryBul, preTemVen.T) annotation (Line(
      points={{-26,48},{-34,48},{-34,-4},{-41.2,-4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(Tset2.y, multizone.ventRate)
    annotation (Line(points={{16.8,24},{20,24},{34.5,24}}, color={0,0,127}));
  connect(occupancyTable.y[1], multizone.intGains[1]) annotation (Line(points={{
          -109,-86},{-109,-86},{72,-86},{72,-11.2}}, color={0,0,127}));
  connect(blind[1].y, multizone.intGains[2]) annotation (Line(points={{85.2,-28},
          {80,-28},{80,-11.2},{72,-11.2}}, color={0,0,127}));
  connect(blind[2].y, multizone.intGains[3]) annotation (Line(points={{85.2,-28},
          {78,-28},{78,-11.2},{72,-11.2}}, color={0,0,127}));
  connect(nairInfilt[1].y, add.u1) annotation (Line(points={{-83.2,8},{-78,8},{-78,
          -10.8},{-57.4,-10.8}}, color={0,0,127}));
  connect(occupancyTable.y[2], add.u2) annotation (Line(points={{-109,-86},{-109,
          -86},{-102,-86},{-102,-19.2},{-57.4,-19.2}}, color={0,0,127}));
  connect(add.y, airExc.InPort1) annotation (Line(points={{-41.3,-15},{-41.3,-14.5},
          {-11.2,-14.5},{-11.2,-13.12}}, color={0,0,127}));
  connect(multizone.intGainsConv[1], convectiveIntGains.port) annotation (Line(
        points={{37,1.6},{37,-42.2},{14,-42.2},{14,-42}}, color={191,0,0}));
  connect(radiativeIntGains.port, multizone.intGainsRad[1]) annotation (Line(
        points={{14,-28},{24,-28},{24,12.48},{37,12.48}}, color={191,0,0}));
  connect(gain.y, convectiveIntGains.Q_flow) annotation (Line(points={{-3.5,-43},
          {-3.5,-42.5},{2,-42.5},{2,-42}}, color={0,0,127}));
  connect(occupancyTable.y[3], gain.u) annotation (Line(points={{-109,-86},{-26,
          -86},{-26,-43},{-15,-43}}, color={0,0,127}));
  connect(gain1.y, radiativeIntGains.Q_flow) annotation (Line(points={{-3.5,-29},
          {-1.75,-29},{-1.75,-28},{2,-28}}, color={0,0,127}));
  connect(occupancyTable.y[3], gain1.u) annotation (Line(points={{-109,-86},{-76,
          -86},{-40,-86},{-40,-29},{-15,-29}}, color={0,0,127}));
  connect(add.y, airExchangeRate) annotation (Line(points={{-41.3,-15},{-21.65,
          -15},{-21.65,4},{-6,4}}, color={0,0,127}));
  annotation (experiment(
      StartTime=-36000,
      StopTime=3.1536e+007,
      Interval=3600,
      __Dymola_Algorithm="Dassl"),
      __Dymola_experimentSetupOutput(events=false),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={
        Line(points={{80,-82}}, color={28,108,200}),
        Rectangle(
          extent={{-80,20},{80,-80}},
          lineColor={0,0,0},
          lineThickness=0.5),
        Line(
          points={{-80,20},{0,100},{80,20}},
          color={0,0,0},
          thickness=0.5),
        Text(
          extent={{-52,-10},{62,-48}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          textString="TB")}));
end Residential2009;
