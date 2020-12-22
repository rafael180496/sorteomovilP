import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

import 'enums.dart';

class License {
  static final License _instance = License.internal();

  factory License() {
    return _instance;
  }

  License.internal();

  Future<bool> initLicense({@required String key}) async {
    bool _sucess = false;
    SharedPreferences _prefs = await _getPreferences();

    String _keyServer = "X";
    String _userServer = "X";
    String _idDocument = "X";
    bool _indimport = false;
    bool _indprint = false;
    Tarifas _tarifario = Tarifas.NORMAL;
    Seleccion _tipo = Seleccion.PREMIO;

    await _getStoreRef()
        .where('key', isEqualTo: key)
        .getDocuments()
        .then((_value) {
      _value.documents.forEach((element) {
        _idDocument = element.documentID;
        _indimport = element.data['import'] == null
            ? false
            : element.data['import'].toString().parseBool();
        _indprint = element.data['print'] == null
            ? false
            : element.data['print'].toString().parseBool();
        _keyServer = element.data['key'];
        _userServer = element.data['user'];
        _tarifario = element.data['tarifa'] == null
            ? Tarifas.NORMAL
            : getTarifasFromString(element.data['tarifa']);
        _tipo = element.data['seleccion'] == null
            ? Seleccion.PREMIO
            : getSeleccionFromString(element.data['seleccion']);
      });
    }).whenComplete(() {
      if (key == _keyServer) {
        _prefs.setString('key', _keyServer);
        _prefs.setBool('avisovenc', false);
        _prefs.setInt('diferenciavenc', 0);
        _prefs.setString('usuario', _userServer);
        _prefs.setBool('import', _indimport);
        _prefs.setBool('print', _indprint);
        _prefs.setString('idDocumento', _idDocument);
        _prefs.setString('tarifa', _tarifario.toString());
        _prefs.setString('tipo', _tipo.toString());
        _sucess = true;
      } else {
        _sucess = false;
      }
    }).catchError((onError) {
      _sucess = false;
    });
    return _sucess;
  }

  Future<bool> vencimiento() async {
    bool _sucess = false;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _documento = await _getIdDocumento();

    if (_documento != " ") {
      await _getStoreRef().document(_documento).get().then((_value) {
        DateTime _feUltimo =
            DateTime.parse(_value.data['feultimo'].toDate().toString());
        DateTime _feVenc =
            DateTime.parse(_value.data['fevenc'].toDate().toString());
        if (_feUltimo.isBefore(_feVenc)) {
          _prefs.setBool('activado', true);
          final diferencia = _feVenc.difference(_feUltimo).inDays;
          if (diferencia <= paramValues["diasvenc"]) {
            _prefs.setBool('avisovenc', true);
            _prefs.setInt('diferenciavenc', diferencia);
          }
          _sucess = true;
        } else {
          _prefs.setBool('activado', false);
          _sucess = false;
        }
      }).catchError((onError) {
        _sucess = false;
      });
    }
    return _sucess;
  }

  Future<bool> parametrosLicencias() async {
    bool _sucess = false;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _documento = await _getIdDocumento();

    Tarifas _tarifario = Tarifas.NORMAL;
    Seleccion _tipo = Seleccion.PREMIO;

    if (_documento != " ") {
      await _getStoreRef().document(_documento).get().then((_value) {
        _tarifario = _value.data['tarifa'] == null
            ? Tarifas.NORMAL
            : getTarifasFromString(_value.data['tarifa']);
        _tipo = _value.data['seleccion'] == null
            ? Seleccion.PREMIO
            : getSeleccionFromString(_value.data['seleccion']);

        _prefs.setString('tarifa', _tarifario.toString());
        _prefs.setString('tipo', _tipo.toString());
        _sucess = true;
      }).catchError((onError) {
        _sucess = false;
      });
    }
    return _sucess;
  }

  actualizarImport() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool('import', false);
    String _documento = await _getIdDocumento();
    Map<String, dynamic> update;
    update = {"import": false};
    await _getStoreRef()
        .document(_documento)
        .updateData(update)
        .whenComplete(() => print("update"))
        .catchError((_onError) {
      print(_onError.toString());
    });
  }

  actualizar() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _documento = await _getIdDocumento();
    await actualizarServerDate();

    if (_documento != " ") {
      DateTime server = await getTimeServer();
      DateTime ven = DateTime.now();
      bool indimport = false;
      bool indprint =false;
      int day, month, year = 0;
      await _getStoreRef().document(_documento).get().then((value) {
        ven = DateTime.parse(value.data['fevenc'].toDate().toString());
        indimport = value.data['import'] == null
            ? false
            : value.data['import'].toString().parseBool();
        indprint = value.data['print'] == null
            ? false
            : value.data['print'].toString().parseBool();
        day = value.data['day'];
        month = value.data['month'];
        year = value.data['year'];
      }).catchError((onError) {
        day = 0;
        month = 0;
        year = 0;
      });
      _prefs.setBool('import', indimport);
      _prefs.setBool('print', indprint);
      if (ven.year != 2999 && ven.month != 12 && ven.day != 31) {
        server = ven;
      }

      Map<String, dynamic> update;
      if (day != 0 || month != 0 || year != 0) {
        DateTime fvenc = DateTime(server.year + year, server.month + month,
            server.day + day, server.hour, server.minute);

        update = {
          "fevenc": fvenc,
          "feultimo": FieldValue.serverTimestamp(),
          'day': 0,
          'month': 0,
          'year': 0
        };
      } else {
        update = {"feultimo": FieldValue.serverTimestamp()};
      }

      await _getStoreRef()
          .document(_documento)
          .updateData(update)
          .whenComplete(() => print("update"))
          .catchError((_onError) {
        print(_onError.toString());
      });
    }
  }

  actualizarServerDate() async {
    await _getStoreRefserver()
        .document('server')
        .updateData({'time': FieldValue.serverTimestamp()})
        .whenComplete(() => print("update"))
        .catchError((_onError) {
          print(_onError.toString());
        });
  }

  Future<DateTime> getTimeServer() async {
    DateTime _feVenc = DateTime.now();
    await _getStoreRefserver()
        .document('server')
        .get()
        .then((value) =>
            _feVenc = DateTime.parse(value.data['time'].toDate().toString()))
        .catchError((onError) {
      _feVenc = DateTime.now();
    });

    return _feVenc;
  }

  CollectionReference _getStoreRefserver() =>
      Firestore.instance.collection("parametros");

  addKeyIdMovil() async {
    SharedPreferences _prefs = await _getPreferences();
    String _documento = await _getIdDocumento();
    String _uuid = _generarUuid();

    if (_documento != " ") {
      await _getStoreRef()
          .document(_documento)
          .updateData({"movilid": _uuid})
          .catchError((onError) => print(onError))
          .whenComplete(() => print("update"));

      _prefs.setString('idMovil', _uuid);
    }
  }

  Future<bool> validateKeyIdMovil() async {
    bool _success = false;
    SharedPreferences _prefs = await _getPreferences();
    String _documento = await _getIdDocumento();
    print(_documento);
    if (_documento != " ") {
      await _getStoreRef().document(_documento).get().then((_value) {
        String _idMovilServer = _value.data['movilid'];
        String _idMovilLocal = _prefs.getString('idMovil') ?? "";
        if (_idMovilServer == "" || _idMovilServer == _idMovilLocal) {
          _success = true;
        } else {
          _prefs.setBool('unauthorized', true);
          _success = false;
        }
      }).catchError((onError) {
        print("Error:" + onError.toString());
        _success = false;
      }).whenComplete(() => print("Termino validateKeyIdMovil"));
    } else {
      _success = true;
    }
    return _success;
  }

  CollectionReference _getStoreRef() =>
      Firestore.instance.collection("licencias");

  Future<String> _getIdDocumento() async {
    SharedPreferences _prefs = await _getPreferences();
    return _prefs.getString('idDocumento') ?? " ";
  }

  _generarUuid() => Uuid().v1();

  _getPreferences() async => await SharedPreferences.getInstance();

  cleanLicense() async {
    SharedPreferences _prefs = await _getPreferences();

    _prefs.setString('key', ' ');
    _prefs.setString('usuario', '');
    _prefs.setString('idDocumento', " ");
    _prefs.setString('idMovil', '');
    _prefs.setBool('activado', false);
  }

  cleanAppUnauthorized() async {
    await DB.db.deleteDB();
    await cleanLicense();
  }
}
