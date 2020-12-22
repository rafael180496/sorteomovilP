import 'package:sorteomovil/src/models/TicketDet.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/inputs/inputs.dart';

import 'config.dart';

final _table = "tickets";

class Tickets {
  Tickets(
      {this.id,
      this.sorteo: -1,
      this.cliente: -1,
      this.fecha,
      this.tarifas: Tarifas.NORMAL,
      this.tarifario});
  int id;
  int sorteo;
  int cliente;
  Sorteo sorteoObj = Sorteo();
  Cliente clienteObj = Cliente();
  DateTime fecha;
  List<TicketsDet> detalle;
  Tarifas tarifas;
  List<DataModel> tarifario;

  factory Tickets.fromJson(Map<String, dynamic> json) => Tickets(
        id: json[columsdb["id"]],
        sorteo: json[columsdb["sr"]],
        cliente: json[columsdb["cl"]],
        fecha: DateTime.parse(json[columsdb["fe"]].toString()),
      );

  Map<String, dynamic> toJson() => {
        columsdb["id"]: id,
        columsdb["sr"]: sorteo,
        columsdb["cl"]: cliente,
        columsdb["fe"]: fecha.toString(),
      };
  String title() =>
      "${sorteoObj.tipoObj.nombre} - ${clienteObj.nombre} - ${fecha.toStr()}";
  double getTotal(String acc) {
    if (detalle.isEmpty) {
      return 0;
    }
    var valor = 0.00;
    detalle.forEach((e) {
      if (e.valorTarifa == -1 &&
          e.premioTarifa == -1 &&
          tarifas == Tarifas.ESPECIAL) {
        var values = _getValueTarifarios(e.cant.toInt(), 0);
        e.valorTarifa = values[0];
        e.premioTarifa = values[1];
        e.tarifas = tarifas;
      }

      valor += e.calculos(acc);
    });
    return valor;
  }

  List _getValueTarifarios(int parse, int option) {
    int premio = 0;
    int valor = 0;

    for (var tarifa in tarifario) {
      if (option == 0) {
        if (parse == tarifa.data.valor) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      } else {
        if (parse == tarifa.data.premio) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      }
    }
    return [valor, premio];
  }
}

class TicketModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["id"]} integer primary key autoincrement, 
  ${columsdb["sr"]} integer not null,
  ${columsdb["cl"]} integer not null,
  ${columsdb["fe"]} text not null)
  ''';

  static Future<List<Tickets>> getAll(
      {DateTime fechaIni,
      DateTime fechaFin,
      int sorteo: -1,
      int cliente: -1,
      inCliente: false,
      inSorteo: false,
      inDet: true}) async {
    SqlGeneric sql = SqlGeneric(table: _table);
    if ((fechaIni != null) && (fechaFin != null)) {
      sql.addWhere(SqlWhere(
          colum: "date(${columsdb["fe"]})",
          valor: "date('${fechaIni.toString()}')",
          valor2: "date('${fechaFin.toString()}')",
          inRange: true));
    }

    if (sorteo >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["sr"], valor: sorteo.toString()));
    }
    if (cliente >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["cl"], valor: cliente.toString()));
    }
    final res = await sql.execMap();
    List<Tickets> result =
        res.isNotEmpty ? res.map((e) => Tickets.fromJson(e)).toList() : [];

    if (inCliente || inSorteo || inDet) {
      for (var i = 0; i < result.length; i++) {
        Tickets vl = result[i];
        vl = await dataExtra(vl,
            inCliente: inCliente, inSorteo: inSorteo, inDet: inDet);
        result[i] = vl;
      }
      if (inSorteo) {
        List<Tickets> newresult = [];
        result.forEach((e) {
          if (e.sorteoObj.infinalizado == 0) {
            newresult.add(e);
          }
        });
        result = newresult;
      }
    }

    return result;
  }

  static Future<Tickets> insert(Tickets model) async {
    final connect = await DB.db.database;
    try {
      model.id = await connect.insert(_table, model.toJson());
      for (var i = 0; i < model.detalle.length; i++) {
        model.detalle[i].ticket = model.id;
      }
      model.detalle = await TicketDetModel.insertAll(model.detalle);
    } catch (e) {
      return null;
    }
    return model;
  }

  static Future<Tickets> getId(int id,
      {inCliente: false, inSorteo: false, inDet: true}) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect
        .query(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
    var data = maps.length > 0 ? Tickets.fromJson(maps.first) : null;
    if (data == null) {
      return data;
    }
    data = await dataExtra(data,
        inCliente: inCliente, inSorteo: inSorteo, inDet: inDet);
    return data;
  }

  static Future<Tickets> dataExtra(Tickets model,
      {bool inCliente: false, bool inSorteo: false, bool inDet: true}) async {
    if (inCliente) {
      model.clienteObj = await ClienteModel.getId(model.cliente);
    }
    if (inSorteo) {
      model.sorteoObj = await SorteoModel.getId(model.sorteo, inTipo: true);
    }
    if (inDet) {
      model.detalle = await TicketDetModel.getAll(ticket: model.id);
    }
    return model;
  }

  static Future<int> delete({int id: -1, int sorteo: -1}) async {
    final connect = await DB.db.database;

    if (id >= 0) {
      await TicketDetModel.deleteAll(ticket: id);
      return await connect
          .delete(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
    }
    if (sorteo >= 0) {
      await TicketDetModel.deleteAll(sorteo: sorteo);
      return await connect
          .delete(_table, where: '${columsdb["sr"]} = ?', whereArgs: [sorteo]);
    }
    return -1;
  }

  static Future<int> deleteAll() async {
    final connect = await DB.db.database;
    return await connect.rawDelete("delete from $_table");
  }
}
