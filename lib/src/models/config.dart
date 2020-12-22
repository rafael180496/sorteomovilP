/*Incluye la ejecucion de la creaciones de tabla */

import 'package:sorteomovil/src/models/Clientes.dart';
import 'package:sorteomovil/src/models/Sorteo.dart';
import 'package:sorteomovil/src/models/Tarifario.dart';
import 'package:sorteomovil/src/models/Ticket.dart';
import 'package:sorteomovil/src/models/tipoSorteo.dart';
import 'package:sqflite/sqflite.dart';

import 'TicketDet.dart';

final Map<String, String> columsdb = {
  "id": "id",
  "nb": "nombre",
  "de": "descripcion",
  "di": "direccion",
  "tl": "telefono",
  "cd": "identificacion",
  "pr": "descuento",
  "fe": "fecha",
  "hr": "hora",
  "vl": "valor",
  "tp": "tipo",
  "sr": "sorteo",
  "cl": "cliente",
  "tk": "ticket",
  "fi": "finalizado",
  "ct": "cantidad",
  "nr": "numero",
  "tr": "tarifa",
  "pm": "premio"
};
execSqlInit(Database db, int version) async {
  await db.execute(TipoSorteoModel.modelSql());
  await db.execute(ClienteModel.modelSql());
  await db.execute(SorteoModel.modelSql());
  await db.execute(TicketModel.modelSql());
  await db.execute(TicketDetModel.modelSql());
  await db.execute(TarifarioModel.modelSql());
}

execSqlDelete() async {
  await TipoSorteoModel.deleteAll();
  await ClienteModel.deleteAll();
  await SorteoModel.deleteAll();
  await TicketModel.deleteAll();
  await TicketDetModel.deleteAll();
  await TarifarioModel.deleteAll();
}
