/*Columnas name*/
import 'package:sorteomovil/src/utils/database.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'config.dart';
final _table = "tiposorteo";

class TipoSorteo {
  TipoSorteo({
    this.id,
    this.nombre,
  });
  static TipoSorteo validate(TipoSorteo model) {

    model.nombre =
        model.nombre.trim() == "" ? valuesMsj["nbdefault"] : model.nombre;
    return model;
  }

  int id;
  String nombre;

  factory TipoSorteo.fromJson(Map<String, dynamic> json) => TipoSorteo(
        id: json[columsdb["id"]],
        nombre: json[columsdb["nb"]],
      );

  Map<String, dynamic> toJson() => {
        columsdb["id"]: id,
        columsdb["nb"]: nombre,
      };
}

class TipoSorteoModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["id"]} integer primary key autoincrement,
  ${columsdb["nb"]} text not null)
  ''';

  static Future<TipoSorteo> insert(TipoSorteo model) async {
    final connect = await DB.db.database;
    model.id = await connect.insert(_table, model.toJson());
    return model;
  }

  static Future<TipoSorteo> getId(int id) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect.query(_table,
        where: '${columsdb["id"]} = ?', whereArgs: [id]);

    return maps.length > 0 ? TipoSorteo.fromJson(maps.first) : null;
  }

  static Future<List<TipoSorteo>> getAll({String nombre: ""}) async {
    SqlGeneric sql = SqlGeneric(table: _table);
    if (nombre.trim().isNotEmpty) {
      sql.addWhere(SqlWhere(colum: columsdb["nb"], valor: nombre));
    }
    final res = await sql.execMap();
    return res.isNotEmpty
        ? res.map((e) => TipoSorteo.fromJson(e)).toList()
        : [];
  }

  static Future<List<DataModel>> getData({String nombre: ""}) async {
    final resp = await getAll(nombre: nombre);
    final data = resp.map((e) => DataModel(id: e.id, valor: e.nombre,data: e)).toList();
    return data.isNotEmpty ? data : [];
  }

  static Future<int> delete(int id) async {
    final connect = await DB.db.database;
    return await connect.delete(_table,
        where: '${columsdb["id"]} = ?', whereArgs: [id]);
  }

  static Future<int> deleteAll() async {
    final connect = await DB.db.database;
    return await connect.rawDelete("delete from $_table");
  }

  static Future<int> update(TipoSorteo todo) async {
    final connect = await DB.db.database;
    return await connect.update(_table, todo.toJson(),
        where: '${columsdb["id"]} = ?', whereArgs: [todo.id]);
  }
}
