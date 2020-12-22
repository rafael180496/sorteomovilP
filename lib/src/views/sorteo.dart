import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:state_persistence/state_persistence.dart';

class SorteoView extends StatefulWidget with NavigationStates {
  @override
  _SorteoViewState createState() => _SorteoViewState();
}

class _SorteoViewState extends State<SorteoView> {
  final _formSorteo = GlobalKey<FormState>();
  TextEditingController _inputFieldDate = TextEditingController(text: "");
  TextEditingController _inputFieldDatemin = TextEditingController(text: "");
  TextEditingController _inputFieldDatemax = TextEditingController(text: "");
  TextEditingController _inputFieldSelect = TextEditingController(text: "");
  final SorteoBloc sorteoBloc = SorteoBloc();
  List<DataModel> tipoSorteoList = [];
  ScrollController scrollController;
  bool dialVisible = true;
  String dateText = "";
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    setState(() {
      TipoSorteoModel.getData().then((items) {
        tipoSorteoList = items;
        if (tipoSorteoList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _warning(context);
          });
        }
      });
    });
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistedStateBuilder(
        builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) =>
            Container(
              child: Scaffold(
                floatingActionButton:
                    buildSpeedDial(dialVisible, onRefresh: () async {
                  await sorteoBloc.getSorteos();
                }, onNew: () async {
                  _formModal(context, "Nuevo Sorteo",
                      Sorteo(valor: snap.data["premio"]), tipoSorteoList);
                }, onFilter: () async {
                  _formFilter(context, tipoSorteoList);
                }),
                resizeToAvoidBottomPadding: false,
                body: SafeArea(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 2.0, bottom: 2.0),
                        child: getSorteoWidget())),
              ),
            ));
  }

  Widget getSorteoWidget() {
    return StreamBuilder(
        stream: sorteoBloc.sorteos,
        builder: (BuildContext context, AsyncSnapshot<List<Sorteo>> snapshot) {
          return getSorteoCardWidget(snapshot);
        });
  }

  Widget getSorteoCardWidget(AsyncSnapshot<List<Sorteo>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              padding: EdgeInsets.only(top: 10, left: 15, right: 3),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, index) {
                Sorteo data = snapshot.data[index];
                return cardLoad(context, data);
              })
          : Container(
              child: Center(
              child: noItemsMessageWidget("Agrega un sorteo"),
            ));
    } else {
      return Center(
        child: loadingDataSorteos(),
      );
    }
  }

  Widget cardLoad(BuildContext context, Sorteo data) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: ExpansionTileCard(
        borderRadius: BorderRadius.circular(20),
        elevation: 10,
        leading: CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: themeGlobal.accentColor,
          child: Text(data.id.toString()),
          maxRadius: 15,
        ),
        title: Text('${data.tipoObj.nombre} - ${data.fecha.toStr()}',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        children: <Widget>[
          Divider(
            color: themeGlobal.dividerColor,
            thickness: 1.0,
            height: 1.0,
          ),
          SizedBox(
            height: 2,
          ),
          Center(
              child: detLabelList([
            DetLabel("Id", data.id.toString()),
            DetLabel("Tipo", data.tipoObj.nombre),
            DetLabel("Sorteo", data.fecha.toStr()),
            DetLabel("Valor", data.valor.toString()),
            DetLabel(
              "Estado",
              data.getFinalizado(),
              ship: true,
              shipColor:
                  data.infinalizado == 1 ? Colors.red : themeGlobal.accentColor,
            ),
          ])),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            buttonHeight: 52.0,
            buttonMinWidth: 90.0,
            children: <Widget>[
              FlatButton(
                splashColor: Colors.red[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () async {
                  await AwesomeDialog(
                          dismissOnTouchOutside: false,
                          context: context,
                          dialogType: DialogType.WARNING,
                          animType: AnimType.BOTTOMSLIDE,
                          title: 'Borrar',
                          desc: 'Desea borrar el sorteo?',
                          btnOkOnPress: () {
                            _validate(data.id, context);
                          },
                          btnCancelOnPress: () {})
                      .show();
                },
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      size: 33,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              FlatButton(
                splashColor: themeGlobal.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () async {
                  _formModal(context, "Editar Sorteo", data, tipoSorteoList);
                },
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      size: 33,
                      color: themeGlobal.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget loadingDataSorteos() {
    sorteoBloc.getSorteos();
    return loadingData();
  }

  _formFilter(BuildContext context, List<DataModel> tipoSorteoList) async {
    DataModel tipoSorteo;
    var idtipo = -1;
    List<Widget> children = [
      InputGeneric(
        controller: _inputFieldDatemin,
        enableInteractiveSelection: false,
        labelText: "Fecha inicio",
        hintText: "ingrese fecha de inicio a filtrar",
        tipo: TipoInput.DatePicker,
        border: false,
        validator: (vl) {},
        onPicker: (vl) {
          setState(() {
            _inputFieldDatemin.text = vl;
          });
        },
      ),
      InputGeneric(
        controller: _inputFieldDatemax,
        enableInteractiveSelection: false,
        labelText: "Fecha fin",
        hintText: "ingrese fecha de fin a filtrar",
        tipo: TipoInput.DatePicker,
        border: false,
        validator: (vl) {},
        onPicker: (vl) {
          setState(() {
            _inputFieldDatemax.text = vl;
          });
        },
      ),
      InputGeneric(
        enableInteractiveSelection: true,
        controller: _inputFieldSelect,
        validator: (vl) {
          if (vl == valuesMsj["defaultTipo"]) {
            return "Ingrese un tipo de sorteo";
          }
          return null;
        },
        labelText: "Tipo de sorteo",
        hintText: "ingrese el tipo de sorteo",
        items: tipoSorteoList,
        item: tipoSorteo,
        tipo: TipoInput.Select,
        labelSelect: "Seleccione el tipo de sorteo",
        border: false,
        onData: (data) {
          setState(() {
            _inputFieldSelect.text = data.valor;
            idtipo = data.id;
          });
        },
      )
    ];

    formModal(context, _formSorteo, preLoad: () async {
      tipoSorteo = DataModel(id: -1, valor: valuesMsj["defaultTipo"]);
      _inputFieldSelect.text = tipoSorteo.valor;
      _inputFieldDatemin.text = paramValues["datemin"];
      _inputFieldDatemax.text = paramValues["datemax"];
    },
        titleColor: themeGlobal.primaryColorDark,
        titleSize: 22,
        titleText: "Filtrar sorteos",
        children: children,
        acciones: [
          AccionBtn(
            colorText: Colors.red,
            textBtn: "Cancelar",
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
          ),
          AccionBtn(
            colorText: themeGlobal.accentColor,
            textBtn: "Filtrar",
            icon: Icons.save,
            onPressed: () async {
              final vlini = DateTime.parse(_inputFieldDatemin.text);
              final vlfin = DateTime.parse(_inputFieldDatemax.text);
              await sorteoBloc.getSorteos(
                  fechaIni: vlini, fechaFin: vlfin, tipo: idtipo);
              Navigator.pop(context);
            },
          )
        ]);
  }

  _warning(BuildContext context) {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Advertencia',
      desc: 'Por favor ingresar un tipo de sorteo.',
      btnOkText: "Ir",
      btnOkColor: themeGlobal.accentColor,
      btnOkOnPress: () {
        navItem(context, NavigationEvents.TiposdeSorteoClickedEvent);
      },
    ).show();
  }

  _validate(int id, BuildContext context) async {
    await TicketModel.delete(sorteo: id);
    await sorteoBloc.deleteSorteo(id);
  }

  _formModal(BuildContext context, String title, Sorteo model,
      List<DataModel> tipoSorteoList) async {
    DataModel tipoSorteo;
    List<Widget> children = [
      InputGeneric(
        controller: _inputFieldDate,
        enableInteractiveSelection: false,
        labelText: "Fecha Sorteo",
        hintText: "ingrese fecha de sorteo",
        tipo: TipoInput.DatePicker,
        border: false,
        validator: (vl) {
          final vlDate = DateTime.parse(vl);
          if (vlDate.compareDate(DateTime.now()) < 0) {
            return "Ingrese una fecha valida";
          }
          return null;
        },
        onPicker: (vl) {
          setState(() {
            _inputFieldDate.text = vl;
            model.fecha = DateTime.parse(vl);
          });
        },
      ),
      InputGeneric(
        enableInteractiveSelection: true,
        initialValue: "${model.valor}",
        labelText: "Valor del sorteo",
        validator: (value) {
          if (value.isEmpty) {
            return "Ingrese un monto";
          }
          var valueParse = double.parse(value);
          return valueParse <= 0 ? "Ingrese un monto" : null;
        },
        hintText: "ingrese el valor del sorteo",
        range: 2,
        tipo: TipoInput.Digit,
        border: false,
        onChanged: (vl) {
          setState(() {
            model.valor = double.parse(vl);
          });
        },
      ),
      InputGeneric(
        enableInteractiveSelection: true,
        controller: _inputFieldSelect,
        validator: (vl) {
          if (vl == valuesMsj["defaultTipo"]) {
            return "Ingrese un tipo de sorteo";
          }
          return null;
        },
        labelText: "Tipo de sorteo",
        hintText: "ingrese el tipo de sorteo",
        items: tipoSorteoList,
        item: tipoSorteo,
        tipo: TipoInput.Select,
        labelSelect: "Seleccione el tipo de sorteo",
        border: false,
        onData: (data) {
          setState(() {
            _inputFieldSelect.text = data.valor;
            model.tipo = data.id;
          });
        },
      )
    ];
    if (model.id != 0 && model.id != null) {
      children.add(
        InputGeneric(
          onToggle: (vl) {
            setState(() {
              model.infinalizado = vl;
            });
          },
          minWidth: 95.0,
          cornerRadius: 18,
          initialLabelIndex: model.infinalizado,
          switchTitle: "Estado",
          switchTitleColor: themeGlobal.primaryColorDark,
          switchTitleSize: 18,
          labelOn: valuesMsj["on"],
          labelOff: valuesMsj["off"],
          iconOn: Icons.alarm_on,
          iconOff: Icons.alarm_off,
          onColor: themeGlobal.accentColor,
          offColor: Colors.red,
          tipo: TipoInput.Switch,
        ),
      );
    }
    formModal(context, _formSorteo, preLoad: () async {
      tipoSorteo = model.tipo == 0
          ? DataModel(id: 0, valor: valuesMsj["defaultTipo"])
          : DataModel(id: model.tipoObj.id, valor: model.tipoObj.nombre);
      _inputFieldSelect.text = tipoSorteo.valor;
      _inputFieldDate.text = model.fecha.toString();
    },
        titleColor: themeGlobal.primaryColorDark,
        titleSize: 22,
        titleText: title,
        children: children,
        acciones: [
          AccionBtn(
            colorText: Colors.red,
            textBtn: "Cancelar",
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
          ),
          AccionBtn(
            colorText: themeGlobal.accentColor,
            textBtn: "Guardar",
            icon: Icons.save,
            onPressed: () async {
              if (_formSorteo.currentState.validate()) {
                if (model.id == 0 || model.id == null) {
                  model.id = null;
                  await sorteoBloc.addSorteo(model);
                } else {
                  await sorteoBloc.updateSorteo(model);
                }
                Navigator.pop(context);
                AwesomeDialog(
                  dismissOnTouchOutside: false,
                  context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  title: 'Exito',
                  desc: 'Datos guardados',
                  btnOkOnPress: () {},
                )..show();
              }
            },
          )
        ]);
  }
}
