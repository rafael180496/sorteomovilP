import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/widget/inputs/inputs.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'config.dart';

final _table = "sorteo";

class Sorteo {
  Sorteo({
    this.id,
    this.tipo: 0,
    this.infinalizado: 0,
    this.valor: 0,
    this.fecha,
  }) {
    this.fecha =
        fecha == null ? DateTime.now() : this.fecha;
  }

  int id;
  int tipo;
  int infinalizado;
  double valor;
  DateTime fecha;
  TipoSorteo tipoObj=TipoSorteo();
  String getFinalizado() {
    return infinalizado == 1 ? valuesMsj["off"] : valuesMsj["on"];
  }
  String getStr()=>"$id-${tipoObj.nombre}-${fecha.toStr()}";
  factory Sorteo.fromJson(Map<String, dynamic> json) => Sorteo(
        id: json[columsdb["id"]],
        tipo: json[columsdb["tp"]],
        infinalizado: json[columsdb["fi"]],
        valor: json[columsdb["vl"]].toDouble(),
        fecha: DateTime.parse(json[columsdb["fe"]].toString()),
      );

  Map<String, dynamic> toJson() => {
        columsdb["id"]: id,
        columsdb["tp"]: tipo,
        columsdb["fi"]: infinalizado,
        columsdb["vl"]: valor,
        columsdb["fe"]: fecha.toString(),
      };
}

class SorteoModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["id"]} integer primary key autoincrement, 
  ${columsdb["tp"]} integer not null,
  ${columsdb["fi"]} integer not null,
  ${columsdb["vl"]} DECIMAL(10,2) not null,
  ${columsdb["fe"]} text not null)
  ''';

  static Future<List<Sorteo>> getAll(
      {DateTime fechaIni,
      DateTime fechaFin,
      int infinalizado: -1,
      int tipo: -1,
      bool inTipo: false}) async {
    SqlGeneric sql = SqlGeneric(table: _table);
    if ((fechaIni != null) && (fechaFin != null)) {
      sql.addWhere(SqlWhere(
          colum: "date(${columsdb["fe"]})",
          valor: "date('${fechaIni.toString()}')",
          valor2: "date('${fechaFin.toString()}')",
          inRange: true));
    }
    if (infinalizado >= 0) {
      sql.addWhere(
          SqlWhere(colum: columsdb["fi"], valor: infinalizado.toString()));
    }
    if (tipo >= 0) {
      sql.addWhere(SqlWhere(colum: columsdb["tp"], valor: tipo.toString()));
    }
    final res = await sql.execMap();
    List<Sorteo> result =
        res.isNotEmpty ? res.map((e) => Sorteo.fromJson(e)).toList() : [];

    if (inTipo) {
      for (var i = 0; i < result.length; i++) {
        Sorteo vl = result[i];
        vl.tipoObj = await TipoSorteoModel.getId(vl.tipo);
        result[i] = vl;
      }
    }
    return result;
  }

  static Future<List<DataModel>> getData() async {
    final resp = await getAll(inTipo: true,infinalizado: 0);
    final data = resp
        .map((e) => DataModel(
            id: e.id, valor: "${e.getStr()}",data: e))
        .toList();
    return data.isNotEmpty ? data : [];
  }

  static Future<Sorteo> insert(Sorteo model) async {
    final connect = await DB.db.database;
    model.id = await connect.insert(_table, model.toJson());
    return model;
  }

  static Future<Sorteo> getId(int id, {bool inTipo: false}) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect
        .query(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
    var data = maps.length > 0 ? Sorteo.fromJson(maps.first) : null;
    if (data == null) {
      return data;
    }
    if (inTipo) {
      data.tipoObj = await TipoSorteoModel.getId(data.tipo);
    }
    return data;
  }

  static Future<int> delete(int id) async {
    final connect = await DB.db.database;
    return await connect
        .delete(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);
  }

  static Future<int> deleteAll() async {
    final connect = await DB.db.database;
    return await connect.rawDelete("delete from $_table");
  }

  static Future<int> update(Sorteo todo) async {
    final connect = await DB.db.database;
    return await connect.update(_table, todo.toJson(),
        where: '${columsdb["id"]} = ?', whereArgs: [todo.id]);
  }
}
