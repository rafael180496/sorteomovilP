import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sorteomovil/src/blocs/cliente/cliente_bloc.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/inputs/fab.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:state_persistence/state_persistence.dart';

class ClientePage extends StatelessWidget with NavigationStates {
  ClientePage({Key key}) : super(key: key);

  final ClienteBloc clienteBloc = ClienteBloc();
  final DismissDirection _dismissDirection = DismissDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    return PersistedStateBuilder(
        builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) =>
            Scaffold(
                resizeToAvoidBottomPadding: false,
                body: SafeArea(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(
                            left: 2.0, right: 2.0, bottom: 2.0),
                        child: Container(child: getClienteWidget()))),
                bottomNavigationBar: bottomAppbar(
                    () {
                      clienteBloc.getClientes();
                    },
                    "Clientes",
                    () {
                      _showClienteSearchSheet(context);
                    }),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: fabAdd(() {
                  _showClienteAddSheet(context, snap);
                })));
  }

  Widget getClienteWidget() {
    return StreamBuilder(
        stream: clienteBloc.clientes,
        builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
          return getClienteCardWidget(snapshot);
        });
  }

  void _showClienteSearchSheet(BuildContext context) {
    final _searchCliente = Cliente();
    final _formCliente = GlobalKey<FormState>();

    showSheet(context, _formCliente,
        titulo: "Busqueda",
        buttonText: "Buscar Cliente",
        formulario: getFormClienteSearch(_searchCliente), onPressed: () {
      _formCliente.currentState.save();
      clienteBloc.getClientes(nombre: _searchCliente.nombre);
      Navigator.pop(context);
    });
  }

  void _showClienteAddSheet(
      BuildContext context, AsyncSnapshot<PersistedData> snap) {
    final _formCliente = GlobalKey<FormState>();
    final _newCliente = Cliente(descuento: snap.data["descuento"]);

    showSheet(context, _formCliente,
        titulo: "Agregar",
        buttonText: "Agregar Cliente",
        formulario: getFormClienteAddUpd(_newCliente), onPressed: () {
      if (_formCliente.currentState.validate()) {
        _formCliente.currentState.save();
        clienteBloc.addCliente(_newCliente);
        Navigator.pop(context);
      }
    });
  }

  void _showClienteUpdatedSheet(BuildContext context, Cliente _updateCliente) {
    final _formCliente = GlobalKey<FormState>();

    showSheet(context, _formCliente,
        titulo: "Editar",
        buttonText: "Actualizar Cliente",
        formulario: getFormClienteAddUpd(_updateCliente), onPressed: () {
      if (_formCliente.currentState.validate()) {
        _formCliente.currentState.save();
        clienteBloc.updateCliente(_updateCliente);
        Navigator.pop(context);
      }
    });
  }

  Widget getClienteCardWidget(AsyncSnapshot<List<Cliente>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, index) {
                Cliente cliente = snapshot.data[index];
                final Widget dismissibleCard = Dismissible(
                    key: ObjectKey(Cliente),
                    background: Container(
                      child: Padding(
                          padding: EdgeInsets.only(left: 35, right: 35),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Borrar",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Borrar",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                      color: Colors.redAccent,
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return await AwesomeDialog(
                              dismissOnTouchOutside: false,
                              context: context,
                              dialogType: DialogType.WARNING,
                              animType: AnimType.BOTTOMSLIDE,
                              title: 'Borrar',
                              desc: 'Desea borrar el cliente?',
                              btnOkOnPress: () {
                                _validate(cliente.id, context);
                              },
                              btnCancelOnPress: () {})
                          .show();
                    },
                    direction: _dismissDirection,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[200], width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.white,
                      child: ListTile(
                          trailing: InkWell(
                            onTap: () {
                              _showClienteUpdatedSheet(context, cliente);
                            },
                            child: Icon(Icons.edit,
                                size: 26.0, color: themeGlobal.accentColor),
                          ),
                          title: Center(
                            child: Text(cliente.nombre.capitalizeString()),
                          )),
                    ));
                return dismissibleCard;
              })
          : Container(
              child: Center(
              child: noItemsMessageWidget("Agrega un cliente"),
            ));
    } else {
      return Center(
        child: loadingDataClientes(),
      );
    }
  }

  Widget loadingDataClientes() {
    clienteBloc.getClientes();
    return noItemsMessageWidget("Agrega un cliente");
  }

  _validate(int id, BuildContext context) async {
    final result = await TicketModel.getAll(cliente: id);
    if (result.isEmpty) {
      clienteBloc.deleteCliente(id);
    } else {
      await AwesomeDialog(
              dismissOnTouchOutside: false,
              context: context,
              dialogType: DialogType.WARNING,
              animType: AnimType.BOTTOMSLIDE,
              title: 'Borrar',
              desc: 'El cliente aun tiene ticket existentes.',
              btnOkOnPress: () {})
          .show();
    }
  }

  dispose() {
    clienteBloc.dispose();
  }
}
