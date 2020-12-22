import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'config.dart';

final _table = "tarifario";

class Tarifario {
  Tarifario({
    this.tarifa,
    this.valor,
    this.premio,
  });

  String tarifa;
  int valor;
  int premio;

  static Tarifario validate(Tarifario model) {
    model.tarifa =
        model.tarifa.trim() == "" ? valuesMsj["nbdefault"] : model.tarifa;

    model.valor = model.valor < 0 ? 0 : model.valor;
    model.premio = model.premio < 0 ? 0 : model.premio;
    return model;
  }

  factory Tarifario.fromJson(Map<String, dynamic> json) => Tarifario(
        tarifa: json[columsdb["tr"]],
        valor: json[columsdb["vl"]],
        premio: json[columsdb["pm"]],
      );

  Map<String, dynamic> toJson() => {
        columsdb["tr"]: tarifa,
        columsdb["vl"]: valor,
        columsdb["pm"]: premio,
      };
}

class TarifarioModel {
  static String modelSql() => '''
  create table $_table ( 
  ${columsdb["tr"]} text, 
  ${columsdb["vl"]} integer not null,
  ${columsdb["pm"]} integer not null)
  ''';

  static Future<Tarifario> insert(Tarifario model) async {
    final connect = await DB.db.database;
    await connect.insert(_table, model.toJson());
    return model;
  }

  static Future<List<DataModel>> getData() async {
    final resp = await getAll();
    final data =
        resp.map((e) => DataModel(id: e.valor, valor: "", data: e)).toList();
    return data.isNotEmpty ? data : [];
  }

  static Future<Tarifario> getPremio(int vl) async {
    final connect = await DB.db.database;
    List<Map> maps = await connect
        .query(_table, where: '${columsdb["vl"]} = ?', whereArgs: [vl]);

    return maps.length > 0 ? Tarifario.fromJson(maps.first) : null;
  }

  static Future<List<Tarifario>> getAll() async {
    SqlGeneric sql = SqlGeneric(
        table: _table, ordenarRaw: 'ORDER BY ${columsdb["vl"]} ASC;');
    final res = await sql.execMap();
    return res.isNotEmpty ? res.map((e) => Tarifario.fromJson(e)).toList() : [];
  }

  static Future<int> deleteAll() async {
    final connect = await DB.db.database;
    return await connect.rawDelete("delete from $_table");
  }
}
