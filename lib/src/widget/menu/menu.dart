import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/utils/enums.dart';

import 'menu_item.dart';

final List<bool> isTaped = [
  true,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
];

void changeHighlight(int index) {
  for (int indexTap = 0; indexTap < isTaped.length; indexTap++) {
    if (indexTap == index) {
      isTaped[index] = true;
    } else {
      isTaped[indexTap] = false;
    }
  }
}

Future<List<MenuItem>> menu(
    BuildContext context, Function onIconPressed) async {
  bool visibleTarifa = await _paramTarifaAuthorized();
  bool visibleImp = await _paramImp();

  return [
    MenuItem(
      icon: Icons.add,
      title: "Nueva Ticket",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.HomePageClickedEvent);
        changeHighlight(0);
      },
      wasTaped: isTaped[0],
    ),
    MenuItem(
      icon: Icons.receipt,
      title: "Tickets",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.TicketListClickedEvent);
        changeHighlight(1);
      },
      wasTaped: isTaped[1],
    ),
    MenuItem(
      icon: Icons.add_alarm,
      title: "Sorteo",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.SorteoPageClickedEvent);
        changeHighlight(2);
      },
      wasTaped: isTaped[2],
    ),
    MenuItem(
      icon: Icons.people,
      title: "Clientes",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.ClientePageClickedEvent);
        changeHighlight(3);
      },
      wasTaped: isTaped[3],
    ),
    MenuItem(
      icon: Icons.build,
      title: "Tipos de Sorteo",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.TiposdeSorteoClickedEvent);
        changeHighlight(4);
      },
      wasTaped: isTaped[4],
    ),
    MenuItem(
      icon: Icons.lock,
      title: "Cierres",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.CierresClickedEvent);
        changeHighlight(5);
      },
      wasTaped: isTaped[5],
    ),
    MenuItem(
      icon: Icons.attach_money,
      title: "Tarifario",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.TarifarioClickedEvent);
        changeHighlight(6);
      },
      wasTaped: isTaped[6],
      isVisible: visibleTarifa,
    ),
    MenuItem(
      icon: Icons.print,
      title: "Impresora",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.ImpClickedEvent);
        changeHighlight(7);
      },
      wasTaped: isTaped[7],
      isVisible: visibleImp,
    ),
    MenuItem(
      icon: Icons.settings,
      title: "Ajuste",
      onTap: () {
        onIconPressed();
        navItem(context, NavigationEvents.AjustePageClickedEvent);
        changeHighlight(8);
      },
      wasTaped: isTaped[8],
    )
  ];
}

Future<bool> _paramTarifaAuthorized() async {
  bool aut = false;
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String tarifa = _prefs.getString('tarifa');
  Tarifas tarifas = getTarifasFromString(tarifa);
  switch (tarifas) {
    case Tarifas.NORMAL:
      aut = false;
      break;
    case Tarifas.ESPECIAL:
      aut = true;
      break;
  }
  return aut;
}

Future<bool> _paramImp() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  final indprint =
  _prefs.getBool("print") == null ? false : _prefs.getBool("print");
  return indprint;
}
