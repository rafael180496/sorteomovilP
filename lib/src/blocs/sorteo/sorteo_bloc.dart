import 'dart:async';

import 'package:sorteomovil/src/models/Sorteo.dart';

class SorteoBloc {
  final _sorteoController = StreamController<List<Sorteo>>.broadcast();

  get sorteos => _sorteoController.stream;

  SorteoBloc() {
    getSorteos();
  }

  getSorteos(
      {DateTime fechaIni,
      DateTime fechaFin,
      int infinalizado: -1,
      int tipo: -1}) async {
    _sorteoController.sink.add(await SorteoModel.getAll(
        tipo: tipo,
        fechaFin: fechaFin,
        fechaIni: fechaIni,
        infinalizado: infinalizado,
        inTipo: true));
  }

  addSorteo(Sorteo sorteo) async {
    await SorteoModel.insert(sorteo);
    getSorteos();
  }

  deleteSorteo(int id) async {
    await SorteoModel.delete(id);
    getSorteos();
  }

  updateSorteo(Sorteo sorteo) async {
    await SorteoModel.update(sorteo);
    getSorteos();
  }

  dispose() {
    _sorteoController.close();
  }
}
