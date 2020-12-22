import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:state_persistence/state_persistence.dart';

class AjusteView extends StatefulWidget with NavigationStates {
  @override
  _AjusteViewState createState() => _AjusteViewState();
}

class _AjusteViewState extends State<AjusteView> {
  final _formAjuste = GlobalKey<FormState>();
  Widget _crearBtnFloat() => FloatingActionButton.extended(
    tooltip: "Guardar datos",
    label: Text("Guardar datos"),
    icon: Icon(
      Icons.save,
      size: 32,
      color: Colors.white,
    ),
    elevation: 6.0,
    onPressed: () {
      if (_formAjuste.currentState.validate()) {
        _formAjuste.currentState.save();
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
    backgroundColor: themeGlobal.accentColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: 20), child: _crearBtnFloat()),
          resizeToAvoidBottomPadding: false,
          body: Padding(
              padding: EdgeInsets.only(top: 50, left: 10, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 35, bottom: 20),
                      child: _titleAjuste(),
                    ),
                    _addForm()
                  ],
                ),
              ))),
    );
  }

  Widget _addForm() => Form(
      key: _formAjuste,
      child: PersistedStateBuilder(
          builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) {
            return Column(
              children: <Widget>[
                Container(
                    child: InputGeneric(
                        onSaved: (vl) async {
                          snap.data["usuario"] = vl;
                          SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                          _prefs.setString("user", vl);
                        },
                        initialValue: snap.data["usuario"],
                        validator: (value) =>
                        value.trim().isEmpty ? "Ingrese una palabra" : null,
                        labelText: "Usuario",
                        hintText: "Nombre de usuario",
                        iconColor: themeGlobal.accentColor,
                        icon: Icons.arrow_forward)),
                Container(
                    child: InputGeneric(
                        onSaved: (vl) => snap.data["premio"] = double.parse(vl),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Ingrese un monto";
                          }
                          var valueParse = double.parse(value);
                          return valueParse < 0 ? "Ingrese un monto" : null;
                        },
                        initialValue: snap.data["premio"].toString(),
                        labelText: "Premio",
                        hintText: "Valor del premio",
                        tipo: TipoInput.Digit,
                        range: 2,
                        iconColor: themeGlobal.accentColor,
                        icon: Icons.arrow_forward)),
                Container(
                    child: InputGeneric(
                        onSaved: (vl) => snap.data["descuento"] = int.parse(vl),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Ingrese un descuento";
                          }
                          var valueParse = int.parse(value);
                          if (valueParse >= 100) {
                            return "Ingrese un descuento menor a 100%";
                          }
                          return valueParse < 0
                              ? "Ingrese un descuento valido"
                              : null;
                        },
                        initialValue: snap.data["descuento"].toString(),
                        labelText: "Descuento",
                        hintText: "Descuento general para clientes",
                        tipo: TipoInput.Digit,
                        range: 0,
                        iconColor: themeGlobal.accentColor,
                        icon: Icons.arrow_forward)),
                Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                        splashColor: themeGlobal.primaryColor,
                        onPressed: () async {
                          final appname =
                              "© ${DateTime.now().year} ${valuesMsj['appname']} ${valuesMsj['version']}";
                          await AwesomeDialog(
                            dismissOnTouchOutside: false,
                            context: context,
                            dialogType: DialogType.INFO,
                            animType: AnimType.SCALE,
                            title: 'Informacion',
                            desc:
                            '$appname : es una aplicacion para ventas de productos con el fin de vender productos al detalle y exportarlos.',
                            btnOkOnPress: () {},
                          ).show();
                        },
                        child: Text(
                          "Acerca de..",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ))),
              ],
            );
          }));

  Widget _titleAjuste() {
    return Text(
      valuesMsj["ajuste"],
      style: TextStyle(
          color: themeGlobal.primaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold),
    );
  }
}
