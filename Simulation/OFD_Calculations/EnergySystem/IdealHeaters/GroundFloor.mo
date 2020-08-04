within OFD_Calculations.EnergySystem.IdealHeaters;
model GroundFloor
  parameter Real ratioRadHeat = 0.3
    "ratio of radiative heat from total heat generated";
  AixLib.Utilities.Interfaces.Star Rad_Livingroom
    annotation (Placement(transformation(extent={{-145,84},{-129,101}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Con_Livingroom annotation(Placement(transformation(extent = {{-143, 64}, {-130, 77}})));
  AixLib.Utilities.Interfaces.Star Rad_Kitchen
    annotation (Placement(transformation(extent={{-146,-38},{-129,-22}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Con_Kitchen annotation(Placement(transformation(extent = {{-145, -66}, {-131, -51}})));
  AixLib.Utilities.Interfaces.Star Rad_Hobby
    annotation (Placement(transformation(extent={{128,90},{146,108}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Con_Hobby annotation(Placement(transformation(extent = {{130, 64}, {146, 82}})));
  AixLib.Utilities.Interfaces.Star Rad_Corridor
    annotation (Placement(transformation(extent={{128,34},{148,54}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Con_Corridor annotation(Placement(transformation(extent = {{130, 7}, {145, 24}})));
  AixLib.Utilities.Interfaces.Star Rad_WC
    annotation (Placement(transformation(extent={{129,-26},{149,-6}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a Con_Storage annotation(Placement(transformation(extent = {{131, -51}, {150, -33}})));
  Modelica.Blocks.Interfaces.RealInput TSet_GF[5] annotation(Placement(transformation(extent = {{-86, 85}, {-58, 115}}), iconTransformation(extent = {{-79, 91}, {-58, 115}})));
  Modelica.Blocks.Math.Gain         PI_livingroom(k=1000)                                                                                              annotation(Placement(transformation(extent = {{-106, -14}, {-86, 6}})));
  Modelica.Blocks.Math.Gain gainConv_livinrgoom(k = 1 - ratioRadHeat) annotation(Placement(transformation(extent = {{-75, 0}, {-66, 9}})));
  Modelica.Blocks.Math.Gain gainRad_livinrgoom(k = ratioRadHeat) annotation(Placement(transformation(extent = {{-74, -17}, {-65, -8}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceConv_livingroom
    "source convective heat livingroom"                                                                              annotation(Placement(transformation(extent = {{-60, -5}, {-40, 15}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceRad_livingroom
    "source radiative heat livingroom"                                                                             annotation(Placement(transformation(extent = {{-59, -23}, {-39, -3}})));
  Modelica.Blocks.Math.Gain         PI_hobby(k=1000)                                                                                              annotation(Placement(transformation(extent = {{25, 73}, {45, 93}})));
  Modelica.Blocks.Math.Gain gainConv_hobby(k = 1 - ratioRadHeat) annotation(Placement(transformation(extent = {{56, 87}, {65, 96}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceRad_hobby
    "source radiative heat hobby"                                                                        annotation(Placement(transformation(extent = {{72, 64}, {92, 84}})));
  Modelica.Blocks.Math.Gain gainRad_hobby(k = ratioRadHeat) annotation(Placement(transformation(extent = {{57, 70}, {66, 79}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceConv_hobby
    "source convective heat hobby"                                                                         annotation(Placement(transformation(extent = {{71, 82}, {91, 102}})));
  Modelica.Blocks.Math.Gain         PI_corridor(k=1000)                                                                                              annotation(Placement(transformation(extent = {{34, 25}, {54, 45}})));
  Modelica.Blocks.Math.Gain gainConv_corridor(k = 1 - ratioRadHeat) annotation(Placement(transformation(extent = {{65, 39}, {74, 48}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceRad_corridor
    "source radiative heat corridor"                                                                           annotation(Placement(transformation(extent = {{81, 16}, {101, 36}})));
  Modelica.Blocks.Math.Gain gainRad_corridor(k = ratioRadHeat) annotation(Placement(transformation(extent = {{66, 22}, {75, 31}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceConv_corridor
    "source convective heat corridor"                                                                            annotation(Placement(transformation(extent = {{80, 34}, {100, 54}})));
  Modelica.Blocks.Math.Gain         PI_WC(k=1000)                                                                                              annotation(Placement(transformation(extent = {{44, -56}, {64, -36}})));
  Modelica.Blocks.Math.Gain gainConv_WC(k = 1 - ratioRadHeat) annotation(Placement(transformation(extent = {{75, -42}, {84, -33}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceRad_WC
    "source radiative heat WC"                                                                     annotation(Placement(transformation(extent = {{91, -65}, {111, -45}})));
  Modelica.Blocks.Math.Gain gainRad_WC(k = ratioRadHeat) annotation(Placement(transformation(extent = {{76, -59}, {85, -50}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceConv_WC
    "source convective heat WC"                                                                      annotation(Placement(transformation(extent = {{90, -47}, {110, -27}})));
  Modelica.Blocks.Math.Gain         PI_kitchen(k=1000)                                                                                              annotation(Placement(transformation(extent = {{-104, -82}, {-84, -62}})));
  Modelica.Blocks.Math.Gain gainConv_kitchen(k = 1 - ratioRadHeat) annotation(Placement(transformation(extent = {{-73, -68}, {-64, -59}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceRad_kitchen
    "source radiative heat kitchen"                                                                          annotation(Placement(transformation(extent = {{-57, -91}, {-37, -71}})));
  Modelica.Blocks.Math.Gain gainRad_kitchen(k = ratioRadHeat) annotation(Placement(transformation(extent = {{-72, -85}, {-63, -76}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow SourceConv_kitchen
    "source convective heat kitchen"                                                                           annotation(Placement(transformation(extent = {{-58, -73}, {-38, -53}})));
equation
  connect(PI_livingroom.y, gainConv_livinrgoom.u) annotation(Line(points = {{-85, -4}, {-80, -4}, {-80, 4.5}, {-75.9, 4.5}}, color = {0, 0, 127}));
  connect(PI_livingroom.y, gainRad_livinrgoom.u) annotation(Line(points = {{-85, -4}, {-80, -4}, {-80, -12.5}, {-74.9, -12.5}}, color = {0, 0, 127}));
  connect(SourceConv_livingroom.Q_flow, gainConv_livinrgoom.y) annotation(Line(points = {{-60, 5}, {-62, 5}, {-62, 4.5}, {-65.55, 4.5}}, color = {0, 0, 127}));
  connect(gainRad_livinrgoom.y, SourceRad_livingroom.Q_flow) annotation(Line(points = {{-64.55, -12.5}, {-61, -12.5}, {-61, -13}, {-59, -13}}, color = {0, 0, 127}));
  connect(SourceConv_livingroom.port, Con_Livingroom) annotation(Line(points = {{-40, 5}, {-22, 5}, {-22, 28}, {-125, 28}, {-125, 70.5}, {-136.5, 70.5}}, color = {191, 0, 0}));
  connect(SourceRad_livingroom.port, Rad_Livingroom) annotation(Line(points = {{-39, -13}, {-22, -13}, {-22, 28}, {-125, 28}, {-125, 92.5}, {-137, 92.5}}, color = {191, 0, 0}));
  connect(PI_hobby.y, gainRad_hobby.u) annotation(Line(points = {{46, 83}, {51, 83}, {51, 74.5}, {56.1, 74.5}}, color = {0, 0, 127}));
  connect(PI_hobby.y, gainConv_hobby.u) annotation(Line(points = {{46, 83}, {51, 83}, {51, 91.5}, {55.1, 91.5}}, color = {0, 0, 127}));
  connect(PI_corridor.y, gainRad_corridor.u) annotation(Line(points = {{55, 35}, {60, 35}, {60, 26.5}, {65.1, 26.5}}, color = {0, 0, 127}));
  connect(PI_corridor.y, gainConv_corridor.u) annotation(Line(points = {{55, 35}, {60, 35}, {60, 43.5}, {64.1, 43.5}}, color = {0, 0, 127}));
  connect(PI_WC.y, gainRad_WC.u) annotation(Line(points = {{65, -46}, {70, -46}, {70, -54.5}, {75.1, -54.5}}, color = {0, 0, 127}));
  connect(PI_WC.y, gainConv_WC.u) annotation(Line(points = {{65, -46}, {70, -46}, {70, -37.5}, {74.1, -37.5}}, color = {0, 0, 127}));
  connect(PI_kitchen.y, gainRad_kitchen.u) annotation(Line(points = {{-83, -72}, {-78, -72}, {-78, -80.5}, {-72.9, -80.5}}, color = {0, 0, 127}));
  connect(PI_kitchen.y, gainConv_kitchen.u) annotation(Line(points = {{-83, -72}, {-78, -72}, {-78, -63.5}, {-73.9, -63.5}}, color = {0, 0, 127}));
  connect(gainConv_hobby.y, SourceConv_hobby.Q_flow) annotation(Line(points = {{65.45, 91.5}, {67.725, 91.5}, {67.725, 92}, {71, 92}}, color = {0, 0, 127}));
  connect(gainRad_hobby.y, SourceRad_hobby.Q_flow) annotation(Line(points = {{66.45, 74.5}, {68.225, 74.5}, {68.225, 74}, {72, 74}}, color = {0, 0, 127}));
  connect(gainRad_corridor.y, SourceRad_corridor.Q_flow) annotation(Line(points = {{75.45, 26.5}, {77.725, 26.5}, {77.725, 26}, {81, 26}}, color = {0, 0, 127}));
  connect(gainConv_corridor.y, SourceConv_corridor.Q_flow) annotation(Line(points = {{74.45, 43.5}, {76.725, 43.5}, {76.725, 44}, {80, 44}}, color = {0, 0, 127}));
  connect(gainConv_WC.y, SourceConv_WC.Q_flow) annotation(Line(points = {{84.45, -37.5}, {87.225, -37.5}, {87.225, -37}, {90, -37}}, color = {0, 0, 127}));
  connect(gainRad_WC.y, SourceRad_WC.Q_flow) annotation(Line(points = {{85.45, -54.5}, {87.225, -54.5}, {87.225, -55}, {91, -55}}, color = {0, 0, 127}));
  connect(gainConv_kitchen.y, SourceConv_kitchen.Q_flow) annotation(Line(points = {{-63.55, -63.5}, {-61.775, -63.5}, {-61.775, -63}, {-58, -63}}, color = {0, 0, 127}));
  connect(gainRad_kitchen.y, SourceRad_kitchen.Q_flow) annotation(Line(points = {{-62.55, -80.5}, {-59.775, -80.5}, {-59.775, -81}, {-57, -81}}, color = {0, 0, 127}));
  connect(SourceConv_kitchen.port, Con_Kitchen) annotation(Line(points = {{-38, -63}, {-23, -63}, {-23, -49}, {-130, -49}, {-130, -58.5}, {-138, -58.5}}, color = {191, 0, 0}));
  connect(SourceRad_kitchen.port, Rad_Kitchen) annotation(Line(points = {{-37, -81}, {-23, -81}, {-23, -30}, {-137.5, -30}}, color = {191, 0, 0}));
  connect(SourceConv_WC.port, Con_Storage) annotation(Line(points = {{110, -37}, {127, -37}, {127, -42}, {140.5, -42}}, color = {191, 0, 0}));
  connect(SourceRad_WC.port, Rad_WC) annotation(Line(points = {{111, -55}, {127, -55}, {127, -16}, {139, -16}}, color = {191, 0, 0}));
  connect(SourceRad_corridor.port, Rad_Corridor) annotation(Line(points = {{101, 26}, {139, 26}, {139, 44}, {138, 44}}, color = {191, 0, 0}));
  connect(SourceConv_corridor.port, Con_Corridor) annotation(Line(points = {{100, 44}, {126, 44}, {126, 10}, {138, 10}, {138, 13}, {137.5, 13}, {137.5, 15.5}}, color = {191, 0, 0}));
  connect(SourceRad_hobby.port, Rad_Hobby) annotation(Line(points = {{92, 74}, {126, 74}, {126, 99}, {137, 99}}, color = {191, 0, 0}));
  connect(SourceConv_hobby.port, Con_Hobby) annotation(Line(points = {{91, 92}, {126, 92}, {126, 73}, {138, 73}}, color = {191, 0, 0}));
  connect(TSet_GF[1], PI_livingroom.u) annotation (Line(points={{-72,88},{-130,
          88},{-130,-4},{-108,-4}}, color={0,0,127}));
  connect(PI_hobby.u, TSet_GF[2]) annotation (Line(points={{23,83},{1,83},{1,94},
          {-72,94}}, color={0,0,127}));
  connect(PI_corridor.u, TSet_GF[3]) annotation (Line(points={{32,35},{0,35},{0,
          99},{-72,99},{-72,100}}, color={0,0,127}));
  connect(PI_WC.u, TSet_GF[4]) annotation (Line(points={{42,-46},{21,-46},{21,
          -47},{1,-47},{1,99},{-72,99},{-72,106}}, color={0,0,127}));
  connect(PI_kitchen.u, TSet_GF[5]) annotation (Line(points={{-106,-72},{-120,
          -72},{-120,-73},{-120,112},{-72,112}}, color={0,0,127}));
  annotation(Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-130, -100}, {130, 100}}, grid = {1, 1}), graphics={  Rectangle(extent = {{1, 100}, {126, 63}}, pattern = LinePattern.Solid, lineColor = {0, 0, 0}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Rectangle(extent = {{3, 58}, {126, 15}}, pattern = LinePattern.Solid, lineColor = {0, 0, 0}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Rectangle(extent = {{1, -14}, {127, -67}}, pattern = LinePattern.Solid, lineColor = {0, 0, 0}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Rectangle(extent = {{-129, 28}, {-22, -26}}, pattern = LinePattern.Solid, lineColor = {0, 0, 0}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Rectangle(extent = {{-130, -49}, {-23, -103}}, pattern = LinePattern.Solid, lineColor = {0, 0, 0}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Text(extent = {{-120, -88}, {-69, -103}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid, textString = "Kitchen"), Text(extent = {{-155, 24}, {-48, 11}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid, textString = "Livingroom"), Text(extent = {{31, -15}, {138, -28}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid, textString = "WC/Storage"), Text(extent = {{49, 58}, {156, 45}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid, textString = "Corridor"), Text(extent = {{51, 99}, {158, 86}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid, textString = "Hobby"), Text(extent = {{-68, 87}, {-15, 55}}, lineColor = {0, 0, 0}, textString = "1 - Livingroom
 2- Hobby
 3 - Corridor
 4 - WC/Storage
 5 - Kitchen")}), Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-130, -100}, {130, 100}}, grid = {1, 1}), graphics={  Rectangle(extent = {{-119, 92}, {123, -79}}, lineColor = {255, 0, 0}, fillColor = {135, 135, 135},
            fillPattern =                                                                                                   FillPattern.Solid), Line(points = {{-99, 22}, {104, 22}, {104, -6}}, color = {255, 0, 0}, thickness = 1), Line(points = {{-98, 13}, {95, 13}, {95, -6}}, color = {0, 0, 255}, thickness = 1), Line(points = {{-21, 13}, {-21, 35}}, color = {0, 0, 255}, thickness = 1), Line(points = {{-14, 23}, {-14, 45}}, color = {255, 0, 0}, thickness = 1), Text(extent = {{-87, 74}, {-34, 42}}, lineColor = {0, 0, 0}, textString = "1 - Livingroom
 2- Hobby
 3 - Corridor
 4 - WC/Storage
 5 - Kitchen")}), Documentation(revisions = "<html>
 <ul>
 <li><i>June 19, 2014</i> by Ana Constantin:<br/>Implemented</li>
 </ul>
 </html>", info = "<html>
 <h4><span style=\"color:#008000\">Overview</span></h4>
 <p>Model for the ground floor.</p>
 </html>"));
end GroundFloor;
