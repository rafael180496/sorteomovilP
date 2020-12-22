import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';

class TipoSorteoPage extends StatelessWidget with NavigationStates {
  TipoSorteoPage({Key key}) : super(key: key);

  final TipoSorteoBloc _tipoSorteoBloc = TipoSorteoBloc();
  final DismissDirection _dismissDirection = DismissDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
                child: Container(child: getTipoSorteoWidget()))),
        bottomNavigationBar: bottomAppbar(
            () {
              _tipoSorteoBloc.getTipoSorteos();
            },
            "Tipos de sorteos",
            () {
              _showTipoSorteoSearchSheet(context);
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: fabAdd(() {
          _showTipoSorteoAddSheet(context);
        }),
      ),
    );
  }

  Widget getTipoSorteoWidget() {
    return StreamBuilder(
        stream: _tipoSorteoBloc.tipoSorteo,
        builder:
            (BuildContext context, AsyncSnapshot<List<TipoSorteo>> snapshot) {
          return getTipoSorteoCardWidget(snapshot);
        });
  }

  void _showTipoSorteoSearchSheet(BuildContext context) {
    final _searchTipoSorteo = TipoSorteo();
    final _formTipoSorteo = GlobalKey<FormState>();

    showSheet(context, _formTipoSorteo,
        titulo: "Busqueda",
        buttonText: "Buscar tipo de Sorteo",
        formulario: getFormTipoSorteoSearch(_searchTipoSorteo), onPressed: () {
      _formTipoSorteo.currentState.save();
      _tipoSorteoBloc.getTipoSorteos(nombre: _searchTipoSorteo.nombre);
      Navigator.pop(context);
    });
  }

  void _showTipoSorteoAddSheet(BuildContext context) {
    final _formTipoSorteo = GlobalKey<FormState>();
    final _newTipoSorteo = TipoSorteo();

    showSheet(context, _formTipoSorteo,
        titulo: "Agregar",
        buttonText: "Agregar Tipo de Sorteo",
        formulario: getFormTipoSorteoAddUpd(_newTipoSorteo), onPressed: () {
      if (_formTipoSorteo.currentState.validate()) {
        _formTipoSorteo.currentState.save();
        _tipoSorteoBloc.addTipoSorteo(_newTipoSorteo);
        Navigator.pop(context);
      }
    });
  }

  void _showTipoSorteoUpdatedSheet(
      BuildContext context, TipoSorteo _updateTipoSorteo) {
    final _formTipodeSorteo = GlobalKey<FormState>();

    showSheet(context, _formTipodeSorteo,
        titulo: "Editar",
        buttonText: "Actualizar Tipo de Sorteo",
        formulario: getFormTipoSorteoAddUpd(_updateTipoSorteo), onPressed: () {
      if (_formTipodeSorteo.currentState.validate()) {
        _formTipodeSorteo.currentState.save();
        _tipoSorteoBloc.updateTipoSorteo(_updateTipoSorteo);
        Navigator.pop(context);
      }
    });
  }

  Widget getTipoSorteoCardWidget(AsyncSnapshot<List<TipoSorteo>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, index) {
                TipoSorteo tipoSorteo = snapshot.data[index];
                final Widget dismissibleCard = Dismissible(
                    key: ObjectKey(TipoSorteo),
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
                              desc: 'Desea borrar el Tipo de Sorteo?',
                              btnOkOnPress: () {
                                _validate(tipoSorteo.id, context);
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
                              _showTipoSorteoUpdatedSheet(context, tipoSorteo);
                            },
                            child: Icon(Icons.edit,
                                size: 26.0, color: themeGlobal.accentColor),
                          ),
                          title: Center(
                            child: Text(tipoSorteo.nombre.capitalizeString()),
                          )),
                    ));
                return dismissibleCard;
              })
          : Container(
              child: Center(
              child: noItemsMessageWidget("Agrega un Tipo de Sorteo"),
            ));
    } else {
      return Center(
        child: loadingDataTipodeSorteo(),
      );
    }
  }

  Widget loadingDataTipodeSorteo() {
    _tipoSorteoBloc.getTipoSorteos();
    return noItemsMessageWidget("Agrega un Tipo de Sorteo");
  }

  dispose() {
    _tipoSorteoBloc.dispose();
  }

  _validate(int id, BuildContext context) async {
    final result = await SorteoModel.getAll(tipo: id);
    if (result.isEmpty) {
      _tipoSorteoBloc.deleteTipoSorteo(id);
    } else {
      await AwesomeDialog(
              dismissOnTouchOutside: false,
              context: context,
              dialogType: DialogType.WARNING,
              animType: AnimType.BOTTOMSLIDE,
              title: 'Borrar',
              desc: 'El tipo aun tiene sorteos existentes.',
              btnOkOnPress: () {})
          .show();
    }
  }
}
