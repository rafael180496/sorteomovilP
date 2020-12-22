import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'config.dart';

final _table = "clientes";

class Cliente {
  Cliente({
    this.id,
    this.nombre,
    this.descuento,
  });

  int id;
  String nombre;
  int descuento;

  static Cliente validate(Cliente model) {
    model.nombre =
        model.nombre.trim() == "" ? valuesMsj["nbdefault"] : model.nombre;

    model.descuento = model.descuento < 0 ? 0 : model.descuento;
    return model;
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json[columsdb["id"]],
        nombre: json[columsdb["nb"]],
        descuento: json[columsdb["pr"]],
      );

  Map<String, dynamic> toJson() => {
        columsdb["id"]: id,
        columsdb["nb"]: nombre,
        columsdb["pr"]: descuento,
      };
}

class ClienteModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["id"]} integer primary key autoincrement, 
  ${columsdb["nb"]} text not null,
  ${columsdb["pr"]} integer not null)
  ''';

  static Future<Cliente> insert(Cliente model) async {
    final connect = await DB.db.database;
    model.id = await connect.insert(_table, model.toJson());
    return model;
  }

  static Future<List<DataModel>> getData() async {
    final resp = await getAll();
    final data =
        resp.map((e) => DataModel(id: e.id, valor: e.nombre, data: e)).toList();
    return data.isNotEmpty ? data : [];
  }

  static Future<Cliente> getId(int id) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect
        .query(_table, where: '${columsdb["id"]} = ?', whereArgs: [id]);

    return maps.length > 0 ? Cliente.fromJson(maps.first) : null;
  }

  static Future<List<Cliente>> getAll({String nombre: ""}) async {
    SqlGeneric sql = SqlGeneric(table: _table);
    if (nombre.trim() == "") {
      sql.addWhere(SqlWhere(colum: columsdb["nb"], valor: nombre));
    }
    final res = await sql.execMap();
    return res.isNotEmpty ? res.map((e) => Cliente.fromJson(e)).toList() : [];
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

  static Future<int> update(Cliente todo) async {
    final connect = await DB.db.database;
    return await connect.update(_table, todo.toJson(),
        where: '${columsdb["id"]} = ?', whereArgs: [todo.id]);
  }
}
