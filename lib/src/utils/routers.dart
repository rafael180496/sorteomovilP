/*Contiene los router del proyecto */
import 'package:flutter/material.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/views/views.dart';
import 'package:sorteomovil/src/widget/widget.dart';

final routers = <String, WidgetBuilder>{
  "splash": (BuildContext ctx) => SplashView(),
  "home": (BuildContext ctx) => TicketNewView(1, Tarifas.NORMAL),
  "side": (BuildContext ctx) => SideBarLayout(),
};
