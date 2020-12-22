import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/utils/utils.dart';

final _table = "ticketsdet";

class TicketsDet {
  TicketsDet(
      {this.ticket,
      this.cant,
      this.valor,
      this.desc,
      this.numero,
      this.sorteo: -1,
      this.tarifas: Tarifas.NORMAL,
      this.premioTarifa: -1,
      this.valorTarifa: -1});
  int ticket, numero, sorteo, desc, premioTarifa, valorTarifa;
  double cant, valor;
  Tarifas tarifas;

  factory TicketsDet.fromJson(Map<String, dynamic> json) => TicketsDet(
        ticket: json[columsdb["tk"]],
        cant: json[columsdb["ct"]].toDouble(),
        valor: json[columsdb["vl"]].toDouble(),
        desc: json[columsdb["pr"]],
        numero: json[columsdb["nr"]],
        sorteo: json[columsdb["sr"]],
      );

  Map<String, dynamic> toJson() => {
        columsdb["tk"]: ticket,
        columsdb["ct"]: cant,
        columsdb["vl"]: valor,
        columsdb["pr"]: desc,
        columsdb["nr"]: numero,
        columsdb["sr"]: sorteo,
      };
  double calculos(String acc) {
    final monto = cant;
    final descfin = cant * (desc / 100);
    final premio = (cant / valor) * paramValues["vlcalc"];
    final total = monto - descfin;

    switch (acc) {
      case "pretotal":
        if (tarifas == Tarifas.NORMAL) {
          return monto.formatterRound();
        } else if (tarifas == Tarifas.ESPECIAL) {
          return valorTarifa.toDouble();
        } else {
          return 0.0;
        }
        break;
      case "total":
        return total.formatterRound();
        break;
      case "desc":
        return descfin.formatterRound();
        break;
      case "premio":
        if (tarifas == Tarifas.NORMAL) {
          return premio.formatterRound();
        } else if (tarifas == Tarifas.ESPECIAL) {
          return premioTarifa.toDouble();
        } else {
          return 0.0;
        }
        break;

      default:
        return 0.00;
        break;
    }
  }
}

class TicketDetModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["tk"]} integer not null, 
  ${columsdb["ct"]} DECIMAL(10,2) not null,
  ${columsdb["vl"]} DECIMAL(10,2) not null,
  ${columsdb["pr"]} integer not null,
  ${columsdb["nr"]} integer  not null,
  ${columsdb["sr"]} integer not null
  )
  ''';

  static Future<List<TicketsDet>> getAll(
      {int ticket: -1, int numero: -1, int sorteo: -1}) async {
    SqlGeneric sql = SqlGeneric(table: _table);
    if (ticket >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["tk"], valor: ticket.toString()));
    }
    if (numero >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["nr"], valor: numero.toString()));
    }
    if (sorteo >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["sr"], valor: sorteo.toString()));
    }
    final res = await sql.execMap();
    List<TicketsDet> result =
        res.isNotEmpty ? res.map((e) => TicketsDet.fromJson(e)).toList() : [];
    return result;
  }

  static Future<TicketsDet> insert(TicketsDet model) async {
    final connect = await DB.db.database;
    await connect.insert(_table, model.toJson());
    return model;
  }

  static List<TicketsDet> addIndex(
      TicketsDet data, List<TicketsDet> datalist, Tarifas tarifas) {
    var index = -1;
    for (var i = 0; i < datalist.length; i++) {
      if (datalist[i].numero == data.numero) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      if (tarifas == Tarifas.ESPECIAL) {
        datalist[index].cant += data.cant;
        datalist[index].premioTarifa += data.premioTarifa;
        datalist[index].valorTarifa += data.valorTarifa;
      } else {
        datalist[index].cant += data.cant;
      }
    } else {
      datalist.add(data);
    }
    return datalist;
  }

  static Future<List<TicketsDet>> insertAll(List<TicketsDet> data) async {
    final connect = await DB.db.database;
    data.forEach((vl) async {
      await connect.insert(_table, vl.toJson());
    });
    return data;
  }

  static Future<TicketsDet> getId(int id) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect
        .query(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
    var data = maps.length > 0 ? TicketsDet.fromJson(maps.first) : null;

    return data;
  }

  static Future<int> deleteAll(
      {int ticket: -1, int id: -1, int sorteo: -1}) async {
    final connect = await DB.db.database;
    if (ticket >= 0) {
      return await connect
          .delete(_table, where: '${columsdb["tk"]} = ?', whereArgs: [ticket]);
    }
    if (id >= 0) {
      return await connect
          .delete(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
    }
    if (sorteo >= 0) {
      return await connect
          .delete(_table, where: '${columsdb["sr"]} = ?', whereArgs: [sorteo]);
    }
    return await connect.rawDelete("delete from $_table");
  }
}
