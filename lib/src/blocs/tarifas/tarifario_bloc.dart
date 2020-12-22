import 'dart:async';

import 'package:sorteomovil/src/models/Tarifario.dart';

class TarifarioBloc {
  final _tarifarioController = StreamController<List<Tarifario>>.broadcast();

  get tarifario => _tarifarioController.stream;

  TarifarioBloc() {
    getTarifarios();
  }

  getTarifarios() async {
    _tarifarioController.sink.add(await TarifarioModel.getAll());
  }

  addTarifarios(Tarifario tarifario) async {
    await TarifarioModel.insert(tarifario);
  }

  deleteAllTarifas() async {
    await TarifarioModel.deleteAll();
  }

  dispose() {
    _tarifarioController.close();
  }
}
