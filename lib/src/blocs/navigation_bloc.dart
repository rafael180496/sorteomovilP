import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/views/ajustes_imp_page.dart';
import 'package:sorteomovil/src/views/cierres.dart';
import 'package:sorteomovil/src/views/tarifario_page.dart';
import 'package:sorteomovil/src/views/views.dart';

enum NavigationEvents {
  HomePageClickedEvent,
  ClientePageClickedEvent,
  AjustePageClickedEvent,
  TiposdeSorteoClickedEvent,
  SorteoPageClickedEvent,
  TicketNewClickedEvent,
  TicketListClickedEvent,
  CierresClickedEvent,
  TarifarioClickedEvent,
  ImpClickedEvent
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc(NavigationStates initialState) : super(initialState);

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.TicketNewClickedEvent:
        var tipo = await setSwitchTipo();
        var tarifa = await getTarifas();
        yield TicketNewView(tipo, tarifa);
        break;
      case NavigationEvents.TicketListClickedEvent:
        var tarifa = await getTarifas();
        yield TicketListView(tarifa);
        break;
      case NavigationEvents.HomePageClickedEvent:
        var tipo = await setSwitchTipo();
        var tarifa = await getTarifas();
        yield TicketNewView(tipo, tarifa);
        break;
      case NavigationEvents.ClientePageClickedEvent:
        yield ClientePage();
        break;
      case NavigationEvents.AjustePageClickedEvent:
        yield AjusteView();
        break;
      case NavigationEvents.TiposdeSorteoClickedEvent:
        yield TipoSorteoPage();
        break;
      case NavigationEvents.SorteoPageClickedEvent:
        yield SorteoView();
        break;
      case NavigationEvents.CierresClickedEvent:
        var tarifa = await getTarifas();
        yield CierresView(tarifa);
        break;
      case NavigationEvents.TarifarioClickedEvent:
        var indimport = await getImport();
        yield TarifarioPage(indimport);
        break;
      case NavigationEvents.ImpClickedEvent:
        var column = await getColumnImp();
        yield AjustesImpView(column[0],column[1]);
        break;
    }
  }
}

navItem(BuildContext context, NavigationEvents nav) {
  BlocProvider.of<NavigationBloc>(context).add(nav);
}

Future<int> setSwitchTipo() async {
  final auxprefs = await SharedPreferences.getInstance();
  final auxtipo = auxprefs.getString('tipo');
  Seleccion tipo = getSeleccionFromString(auxtipo);
  int resultado = 1;
  switch (tipo) {
    case Seleccion.PREMIO:
      resultado = 1;
      break;
    case Seleccion.VALOR:
      resultado = 0;
      break;
  }
  return resultado;
}

Future<bool> getImport() async {
  final auxprefs = await SharedPreferences.getInstance();
  final indimport = auxprefs.getBool('import');
  return indimport;
}

Future<bool> getPrint() async {
  final auxprefs = await SharedPreferences.getInstance();
  final indPrint =
      auxprefs.getBool('print') == null ? false : auxprefs.getBool('print');
  return indPrint;
}

Future<Tarifas> getTarifas() async {
  final auxprefs = await SharedPreferences.getInstance();
  final auxtarifas = auxprefs.getString('tarifa');
  return getTarifasFromString(auxtarifas);
}

Future<List> getColumnImp() async {
  final auxprefs = await SharedPreferences.getInstance();
  return [
    auxprefs.getBool('col_premio') ?? false,
    auxprefs.getBool('col_valor') ?? true
  ];
}
