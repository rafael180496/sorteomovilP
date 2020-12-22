import 'dart:async';

import 'package:sorteomovil/src/models/models.dart';

class TipoSorteoBloc {
  final _tipoSorteoController = StreamController<List<TipoSorteo>>.broadcast();

  get tipoSorteo => _tipoSorteoController.stream;

  TipoSorteoBloc() {
    getTipoSorteos();
  }

  getTipoSorteos({String nombre = ""}) async {
    _tipoSorteoController.sink
        .add(await TipoSorteoModel.getAll(nombre: nombre));
  }

  addTipoSorteo(TipoSorteo tipoSorteo) async {
    await TipoSorteoModel.insert(tipoSorteo);
    getTipoSorteos();
  }

  updateTipoSorteo(TipoSorteo tipoSorteo) async {
    await TipoSorteoModel.update(tipoSorteo);
    getTipoSorteos();
  }

  deleteTipoSorteo(int id) async {
    await TipoSorteoModel.delete(id);
    getTipoSorteos();
  }

  dispose() {
    _tipoSorteoController.close();
  }
}
