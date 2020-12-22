/*configuracion de base  de datos  */

import 'dart:io';
import 'package:path/path.dart';
import 'package:sorteomovil/src/models/config.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

enum Where { and, or, where }

String getWhereString(Where tipo) {
  return tipo.toString().replaceAll(valuesMsj["w"], "").trim();
}

/*Single toon */
class DB {
  static Database _database;
  static final DB db = DB._();
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  DB._();
  Future close() async => db.close();
  initDB() async {
    Directory documentsDirect = await getApplicationDocumentsDirectory();
    final path = join(documentsDirect.path, paramValues["dbname"]);
    return await openDatabase(path,
        version: paramValues["dbversion"],
        onOpen: (db) {},
        onCreate: execSqlInit);
  }

  deleteDB() async {
    await execSqlDelete();
  }
}

class SqlGeneric {
  String table;
  List<SqlWhere> condicionales = [];
  List<String> condicionalesRaw = [];
  String ordenarRaw;
  SqlGeneric({this.table: "", this.condicionales, this.ordenarRaw}) {
    condicionales = this.condicionales == null ? [] : this.condicionales;
    condicionalesRaw =
        this.condicionalesRaw == null ? [] : this.condicionalesRaw;
  }
  String sqlgeneric() {
    var sql = '''
    select *
    from $table
    ''';
    if (condicionales.isNotEmpty) {
      var indprimary = true;
      condicionales.forEach((vl) {
        vl.inPrimary = indprimary;
        sql = "$sql ${vl.genSql()}";
        indprimary = false;
      });
    }
    if (condicionalesRaw.isNotEmpty) {
      condicionalesRaw.forEach((vl) {
        sql = "$sql $vl";
      });
    }
    if (ordenarRaw != null) {
      sql = "$sql $ordenarRaw";
    }
    return sql;
  }

  Future<List<Map<String, dynamic>>> execMap() async {
    final db = await DB.db.database;
    return await db.rawQuery(sqlgeneric());
  }

  addWhere(SqlWhere value) {
    condicionales.add(value);
  }

  addWhereRaw(String value) {
    condicionalesRaw.add(value);
  }

  deleteWhere(int index) {
    condicionales.removeAt(index);
  }

  deleteWhereRaw(int index) {
    condicionalesRaw.removeAt(index);
  }
}

class SqlWhere {
  String valor, valor2;
  String colum;
  bool inPrimary, inSpace, inRange;
  Where tipo;
  SqlWhere(
      {this.valor: "",
      this.valor2: "",
      this.colum: "",
      this.inSpace: true,
      this.inPrimary: false,
      this.inRange: false,
      this.tipo: Where.and});

  String genSql() {
    var result = "";
    final condicional = getWhereString(tipo);
    final primary = inPrimary ? getWhereString(Where.where) : condicional;
    final vl = inSpace ? ''' '%$valor%' ''' : ' $valor ';
    if (!inRange) {
      result = '''$primary $colum LIKE $vl ''';
    } else {
      result = '''$primary ( $colum >= $valor and $colum <= $valor2 ) ''';
    }
    return result;
  }
}
