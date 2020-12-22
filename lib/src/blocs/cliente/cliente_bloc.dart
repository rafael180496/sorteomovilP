import 'dart:async';

import 'package:sorteomovil/src/models/Clientes.dart';

class ClienteBloc {
  final _clienteController = StreamController<List<Cliente>>.broadcast();

  get clientes => _clienteController.stream;

  ClienteBloc() {
    getClientes();
  }

  getClientes(
      {String nombre: ""}) async {
    _clienteController.sink.add(await ClienteModel.getAll(
        nombre: nombre));
  }

  addCliente(Cliente cliente) async {
    await ClienteModel.insert(cliente);
    getClientes();
  }

  deleteCliente(int id) async {
    await ClienteModel.delete(id);
    getClientes();
  }

  updateCliente(Cliente cliente) async {
    await ClienteModel.update(cliente);
    getClientes();
  }

  dispose() {
    _clienteController.close();
  }
}
