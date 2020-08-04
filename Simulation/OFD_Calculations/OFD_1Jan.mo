within OFD_Calculations;
model OFD_1Jan "OFD with TMC, TIR and TRY"
  import AixLib;
  extends Modelica.Icons.Example;
  parameter AixLib.DataBase.Weather.TRYWeatherBaseDataDefinition weatherDataDay = AixLib.DataBase.Weather.TRYWinterDay();
  replaceable package Medium = Modelica.Media.Water.ConstantPropertyLiquidWater
    "Medium in the system"                                                                             annotation(Dialog(group = "Medium"), choicesAllMatching = true);
  parameter AixLib.DataBase.Profiles.Profile_BaseDataDefinition VentilationProfile = AixLib.DataBase.Profiles.Ventilation_2perDay_Mean05perH();
  parameter AixLib.DataBase.Profiles.Profile_BaseDataDefinition TSetProfile = AixLib.DataBase.Profiles.SetTemperatures_Ventilation2perDay();
  OFD_IdealHeaters                                                                                 OFD(TIR = 3,
      withDynamicVentilation=false)                                                                             annotation(Placement(transformation(extent={{95,-20},
            {154,19}})));
  inner Modelica.Fluid.System system annotation(Placement(transformation(extent = {{181, 78.5}, {200.5, 99.5}})));
  Modelica.Blocks.Sources.CombiTimeTable NaturalVentilation(columns = {2, 3, 4, 5, 6}, extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, tableOnFile = false, table = VentilationProfile.Profile) annotation(Placement(transformation(extent = {{18, 25}, {38, 45}})));
  Modelica.Blocks.Sources.CombiTimeTable TSet(                              extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic,                      table = TSetProfile.Profile,
    tableOnFile=true,
    tableName="AllRooms",
    columns={2,3,4,5,6,7},
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    fileName="D:/MeineDaten/Stipendium/PaperAnnex/Datasets/InputSignalPRBS.mat")                                                                                                            annotation(Placement(transformation(extent = {{20, -23}, {40, -3}})));
  Modelica.Blocks.Interfaces.RealOutput TAirRooms[10](unit = "degC") annotation(Placement(transformation(extent = {{177, 11}, {197, 31}}), iconTransformation(extent = {{171, -29}, {187, -13}})));
  Modelica.Blocks.Interfaces.RealOutput Toutside(unit = "degC") annotation(Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {142, -111}), iconTransformation(extent = {{172, -95}, {188, -79}})));
  Modelica.Blocks.Interfaces.RealOutput SolarRadiation[6](unit = "W/m2") annotation(Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {186, -112}), iconTransformation(extent = {{172, -95}, {188, -79}})));
  Modelica.Blocks.Interfaces.RealOutput VentilationSchedule[4] annotation(Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {100, -111}), iconTransformation(extent = {{171, -29}, {187, -13}})));
  Modelica.Blocks.Interfaces.RealOutput TsetValvesSchedule[5](unit = "degC") annotation(Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {121, -111}), iconTransformation(extent = {{171, -29}, {187, -13}})));
protected
  AixLib.Building.Components.Weather.Weather Weather(Latitude = 49.5, Longitude = 8.5, GroundReflection = 0.2, tableName = "wetter", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic,                                                                                                 Wind_dir = false, Wind_speed = true, Air_temp = true,
    Sky_rad=true,
    fileName="D:/GIT/AixLib/AixLib/Resources/weatherdata/TRY2010_12_Jahr_Modelica-Library.txt",
    SOD=AixLib.DataBase.Weather.SurfaceOrientation.SurfaceOrientationData_N_E_S_W_RoofN_Roof_S(
        nSurfaces=7,
        name={"N","O","S","W","Roof_N","Roof_S","Horizontal"},
        Azimut={180,-90,0,90,180,0,0},
        Tilt={90,90,90,90,45,45,0}))                                                                                                                                                                                      annotation(Placement(transformation(extent = {{-199, 69}, {-151, 101}})));

public
  Modelica.Blocks.Interfaces.RealOutput PHeatTot(unit="W") annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={5,-110}), iconTransformation(extent={{172,-95},{188,-79}})));
  Modelica.Blocks.Interfaces.RealOutput VentilationLossesTot(unit="W")
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={26,-110}), iconTransformation(extent={{172,-95},{188,-79}})));
  Modelica.Blocks.Interfaces.RealOutput TAirRoomsAvg(unit="degC") annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-16,-110}), iconTransformation(extent={{171,-29},{187,-13}})));
  Modelica.Blocks.Interfaces.RealOutput PhiG "in W/m2"
    annotation (Placement(transformation(extent={{-113,-108},{-93,-88}})));
  Modelica.Blocks.Interfaces.RealOutput Papp "in W"
    annotation (Placement(transformation(extent={{-113,-122},{-93,-102}})));
  Modelica.Blocks.Sources.Constant const(k=0)
    annotation (Placement(transformation(extent={{-148,-123},{-128,-103}})));
equation
  // Romm Temperatures
  TAirRooms[1] = Modelica.SIunits.Conversions.to_degC(OFD.GF.Livingroom.airload.port.T);
  TAirRooms[2] = Modelica.SIunits.Conversions.to_degC(OFD.GF.Hobby.airload.port.T);
  TAirRooms[3] = Modelica.SIunits.Conversions.to_degC(OFD.GF.Corridor.airload.port.T);
  TAirRooms[4] = Modelica.SIunits.Conversions.to_degC(OFD.GF.WC_Storage.airload.port.T);
  TAirRooms[5] = Modelica.SIunits.Conversions.to_degC(OFD.GF.Kitchen.airload.port.T);
  TAirRooms[6] = Modelica.SIunits.Conversions.to_degC(OFD.UF.Bedroom.airload.port.T);
  TAirRooms[7] = Modelica.SIunits.Conversions.to_degC(OFD.UF.Children1.airload.port.T);
  TAirRooms[8] = Modelica.SIunits.Conversions.to_degC(OFD.UF.Corridor.airload.port.T);
  TAirRooms[9] = Modelica.SIunits.Conversions.to_degC(OFD.UF.Bath.airload.port.T);
  TAirRooms[10] = Modelica.SIunits.Conversions.to_degC(OFD.UF.Children2.airload.port.T);
  //SimulationData
  VentilationSchedule[1] = NaturalVentilation.y[1];
  VentilationSchedule[2] = NaturalVentilation.y[2];
  VentilationSchedule[3] = NaturalVentilation.y[3];
  VentilationSchedule[4] = NaturalVentilation.y[4];
  TsetValvesSchedule[1] = Modelica.SIunits.Conversions.to_degC(TSet.y[1]);
  TsetValvesSchedule[2] = Modelica.SIunits.Conversions.to_degC(TSet.y[2]);
  TsetValvesSchedule[3] = Modelica.SIunits.Conversions.to_degC(TSet.y[3]);
  TsetValvesSchedule[4] = Modelica.SIunits.Conversions.to_degC(TSet.y[4]);
  TsetValvesSchedule[5] = Modelica.SIunits.Conversions.to_degC(TSet.y[5]);
  Toutside = Modelica.SIunits.Conversions.to_degC(Weather.AirTemp);
  //SolarRadiation
  SolarRadiation[1] = Weather.SolarRadiation_OrientedSurfaces[1].I;
  SolarRadiation[2] = Weather.SolarRadiation_OrientedSurfaces[2].I;
  SolarRadiation[3] = Weather.SolarRadiation_OrientedSurfaces[3].I;
  SolarRadiation[4] = Weather.SolarRadiation_OrientedSurfaces[4].I;
  SolarRadiation[5] = Weather.SolarRadiation_OrientedSurfaces[5].I;
  SolarRadiation[6] = Weather.SolarRadiation_OrientedSurfaces[6].I;
  VentilationLossesTot = OFD.GF.Livingroom.NaturalVentilation.Q_flow+OFD.GF.Livingroom.infiltrationRate.Q_flow+
                          OFD.GF.Hobby.NaturalVentilation.Q_flow+OFD.GF.Hobby.infiltrationRate.Q_flow+
                          OFD.GF.Corridor.NaturalVentilation.Q_flow+OFD.GF.Corridor.infiltrationRate.Q_flow+
                          OFD.GF.WC_Storage.NaturalVentilation.Q_flow+OFD.GF.WC_Storage.infiltrationRate.Q_flow+
                          OFD.GF.Kitchen.NaturalVentilation.Q_flow+OFD.GF.Kitchen.infiltrationRate.Q_flow+
                          OFD.UF.Bedroom.NaturalVentilation.Q_flow+OFD.UF.Bedroom.infiltrationRate.Q_flow+
                          OFD.UF.Children1.NaturalVentilation.Q_flow+OFD.UF.Children1.infiltrationRate.Q_flow+
                          OFD.UF.Corridor.NaturalVentilation.Q_flow+OFD.UF.Corridor.infiltrationRate.Q_flow+
                          OFD.UF.Bath.NaturalVentilation.Q_flow+OFD.UF.Bath.infiltrationRate.Q_flow+
                          OFD.UF.Children2.NaturalVentilation.Q_flow+OFD.UF.Children2.infiltrationRate.Q_flow;
  PHeatTot = -OFD.GF_Hydraulic.Rad_Livingroom.Q_flow-OFD.GF_Hydraulic.Con_Livingroom.Q_flow
             -OFD.GF_Hydraulic.Rad_Hobby.Q_flow-OFD.GF_Hydraulic.Con_Hobby.Q_flow
             -OFD.GF_Hydraulic.Rad_Corridor.Q_flow-OFD.GF_Hydraulic.Con_Corridor.Q_flow
             -OFD.GF_Hydraulic.Rad_WC.Q_flow-OFD.GF_Hydraulic.Con_Storage.Q_flow
             -OFD.GF_Hydraulic.Rad_Kitchen.Q_flow-OFD.GF_Hydraulic.Con_Kitchen.Q_flow
             -OFD.UF_Hydraulic.Rad_Bedroom.Q_flow-OFD.UF_Hydraulic.Con_Bedroom.Q_flow
             -OFD.UF_Hydraulic.Rad_Children1.Q_flow-OFD.UF_Hydraulic.Con_Children1.Q_flow
             -OFD.UF_Hydraulic.Rad_Bath.Q_flow-OFD.UF_Hydraulic.Con_Bath.Q_flow
             -OFD.UF_Hydraulic.Rad_Children2.Q_flow-OFD.UF_Hydraulic.Con_Children2.Q_flow;
  TAirRoomsAvg = (OFD.GF.Livingroom.airload.port.T*OFD.GF.Livingroom.airload.V
                  +OFD.GF.Hobby.airload.port.T*OFD.GF.Hobby.airload.V
                  +OFD.GF.Corridor.airload.port.T*OFD.GF.Corridor.airload.V
                  +OFD.GF.WC_Storage.airload.port.T*OFD.GF.WC_Storage.airload.V
                  +OFD.GF.Kitchen.airload.port.T*OFD.GF.Kitchen.airload.V
                  +OFD.UF.Bedroom.airload.T*OFD.UF.Bedroom.airload.V
                  +OFD.UF.Children1.airload.T*OFD.UF.Children1.airload.V
                  +OFD.UF.Corridor.airload.T*OFD.UF.Corridor.airload.V
                  +OFD.UF.Bath.airload.T*OFD.UF.Bath.airload.V
                  +OFD.UF.Children2.airload.T*OFD.UF.Children2.airload.V)
                  /(OFD.GF.Livingroom.airload.V+OFD.GF.Hobby.airload.V+OFD.GF.Corridor.airload.V+OFD.GF.WC_Storage.airload.V+OFD.GF.Kitchen.airload.V
                  +OFD.UF.Bedroom.airload.V+OFD.UF.Children1.airload.V+OFD.UF.Corridor.airload.V+OFD.UF.Bath.airload.V+OFD.UF.Children2.airload.V)-273.15;
  PhiG=Weather.SolarRadiation_OrientedSurfaces[7].I;
  connect(NaturalVentilation.y[1], OFD.NaturalVentilation_UF[1]) annotation(Line(points={{39,35},
          {59,35},{59,8.47},{94.6067,8.47}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[1], OFD.NaturalVentilation_GF[1]) annotation(Line(points={{39,35},
          {59,35},{59,-0.11},{95,-0.11}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[2], OFD.NaturalVentilation_UF[2]) annotation(Line(points={{39,35},
          {59,35},{59,10.03},{94.6067,10.03}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[2], OFD.NaturalVentilation_GF[2]) annotation(Line(points={{39,35},
          {59,35},{59,1.45},{95,1.45}},                                                                                                 color = {0, 0, 127}));
  connect(TSet.y[1], OFD.TSet_UF[1]) annotation(Line(points={{41,-13},{59,-13},
          {59,-9.81125},{94.8033,-9.81125}},                                                                               color = {0, 0, 127}));
  connect(TSet.y[1], OFD.TSet_GF[1]) annotation(Line(points={{41,-13},{59,-13},{
          59,-19.298},{95,-19.298}},                                                                                color = {0, 0, 127}));
  connect(TSet.y[2], OFD.TSet_UF[2]) annotation(Line(points={{41,-13},{59,-13},
          {59,-8.15375},{94.8033,-8.15375}},                                                                               color = {0, 0, 127}));
  connect(TSet.y[2], OFD.TSet_GF[2]) annotation(Line(points={{41,-13},{59,-13},{
          59,-17.894},{95,-17.894}},                                                                                color = {0, 0, 127}));
  connect(TSet.y[6], OFD.TSet_GF[3]) annotation(Line(points={{41,-13},{60,-13},{
          60,-16.49},{95,-16.49}},                                                                                color = {0, 0, 127}));
  connect(TSet.y[4], OFD.TSet_UF[3]) annotation(Line(points={{41,-13},{60,-13},
          {60,-6.49625},{94.8033,-6.49625}},                                                                               color = {0, 0, 127}));
  connect(TSet.y[5], OFD.TSet_GF[4]) annotation(Line(points={{41,-13},{59,-13},{
          59,-15.086},{95,-15.086}},                                                                                color = {0, 0, 127}));
  connect(TSet.y[3], OFD.TSet_UF[4]) annotation(Line(points={{41,-13},{60,-13},
          {60,-4.83875},{94.8033,-4.83875}},                                                                               color = {0, 0, 127}));
  connect(TSet.y[3], OFD.TSet_GF[5]) annotation(Line(points={{41,-13},{60,-13},{
          60,-27},{95,-27},{95,-13.682}},                                                                                  color = {0, 0, 127}));
  connect(NaturalVentilation.y[3], OFD.NaturalVentilation_UF[4]) annotation(Line(points={{39,35},
          {60,35},{60,13.15},{94.6067,13.15}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[3], OFD.NaturalVentilation_GF[4]) annotation(Line(points={{39,35},
          {59,35},{59,4.57},{95,4.57}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[4], OFD.NaturalVentilation_UF[3]) annotation(Line(points={{39,35},
          {60,35},{60,11.59},{94.6067,11.59}},                                                                                                 color = {0, 0, 127}));
  connect(NaturalVentilation.y[4], OFD.NaturalVentilation_GF[3]) annotation(Line(points={{39,35},
          {59,35},{59,3.01},{95,3.01}},                                                                                                 color = {0, 0, 127}));
  connect(Weather.WindSpeed, OFD.WindSpeedPort) annotation(Line(points={{-149.4,
          94.6},{-126,94.6},{-126,70},{101.293,70},{101.293,21.73}},                                                                                  color = {0, 0, 127}));
  connect(OFD.Air_Temp, Weather.AirTemp) annotation(Line(points={{138.267,21.73},
          {138.267,70},{-126,70},{-126,90},{-149.4,90},{-149.4,89.8}},                                                                                     color = {0, 0, 127}));
  connect(const.y, Papp) annotation (Line(points={{-127,-113},{-121,-113},{-121,
          -112},{-103,-112}}, color={0,0,127}));
  connect(Weather.SolarRadiation_OrientedSurfaces, OFD.SolarRadiationPort)
    annotation (Line(points={{-187.48,67.4},{-187.48,58},{153,58},{153,17.05},{
          152.033,17.05}},
                   color={255,128,0}));
  annotation(Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-200, -100}, {200, 100}}, grid = {1, 1}), graphics={  Rectangle(extent = {{-63, 15}, {-28, -13}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid), Rectangle(extent = {{-23, 50}, {12, 22}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid), Text(extent = {{-35, 45}, {15, 43}}, lineColor = {0, 0, 255}, textString = "1-Bedroom"), Text(extent = {{-35, 39}, {15, 37}}, lineColor = {0, 0, 255}, textString = "2-Children1"), Text(extent = {{-35, 33}, {15, 31}}, lineColor = {0, 0, 255}, textString = "3-Bath"), Text(extent = {{-35, 27}, {15, 25}}, lineColor = {0, 0, 255}, textString = "4-Children2"), Text(extent = {{-76, 13}, {-26, 11}}, lineColor = {0, 0, 255}, textString = "1-Livingroom"), Text(extent = {{-76, 7}, {-26, 5}}, lineColor = {0, 0, 255}, textString = "2-Hobby"), Text(extent = {{-76, 1}, {-26, -1}}, lineColor = {0, 0, 255}, textString = "3-Corridor"), Text(extent = {{-76, -5}, {-26, -7}}, lineColor = {0, 0, 255}, textString = "4-WC"), Text(extent = {{-76, -11}, {-26, -13}}, lineColor = {0, 0, 255}, textString = "5-Kitchen"), Text(extent = {{-3, 38}, {13, 49}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "UF"), Rectangle(extent = {{-63, 50}, {-28, 22}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid), Text(extent = {{-43, 38}, {-27, 49}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "GF"), Text(extent = {{-75, 41}, {-25, 39}}, lineColor = {0, 0, 255}, textString = "1-Livingroom"), Text(extent = {{-75, 35}, {-25, 33}}, lineColor = {0, 0, 255}, textString = "2-Hobby"), Text(extent = {{-75, 29}, {-25, 27}}, lineColor = {0, 0, 255}, textString = "3-WC"), Text(extent = {{-76, 25}, {-26, 23}}, lineColor = {0, 0, 255}, textString = "4-Kitchen"), Rectangle(extent = {{-23, 15}, {12, -13}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid), Text(extent = {{-43, 3}, {-27, 14}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "GF"), Text(extent = {{-3, 3}, {13, 14}}, lineColor = {0, 0, 255}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "UF"), Text(extent = {{-32, 10}, {18, 8}}, lineColor = {0, 0, 255}, textString = "1-Bedroom"), Text(extent = {{-32, 4}, {18, 2}}, lineColor = {0, 0, 255}, textString = "2-Children1"), Text(extent = {{-32, -2}, {18, -4}}, lineColor = {0, 0, 255}, textString = "3-Bath"), Text(extent = {{-32, -8}, {18, -10}}, lineColor = {0, 0, 255}, textString = "4-Children2")}), Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-200, -100}, {200, 100}}, grid = {1, 1}), graphics), experiment(
      StopTime=3.1536e+007,
      Interval=300,
      __Dymola_Algorithm="Lsodar"),                                                                                                                                                                                                        experimentSetupOutput(
      states=false,
      derivatives=false,
      inputs=false,
      auxiliaries=false,
      events=false),                                                                                                                                                                                                        Documentation(info = "<html>
 <h4><span style=\"color:#008000\">Overview</span></h4>
 <p>Example for setting up a simulation for a one family dwelling.</p>
 <h4><span style=\"color:#008000\">Concept</span></h4>
 <p>Energy generation and delivery system consisting of boiler and pump.</p>
 <p>The example works for a day and shows how such a simulation can be set up. It is not guranteed that the model will work stable under sifferent conditions or for longer periods of time.</p>
 </html>", revisions = "<html>
 <ul>
 <li><i>June 19, 2014</i> by Ana Constantin:<br/>Implemented</li>
 </ul>
 </html>"));
end OFD_1Jan;
