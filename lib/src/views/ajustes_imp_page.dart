import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/views/discovery_page.dart';
import 'package:sorteomovil/src/widget/widget.dart';

class AjustesImpView extends StatefulWidget with NavigationStates {
  final premio;
  final valor;

  AjustesImpView(this.premio, this.valor);

  @override
  _AjustesImpViewState createState() => _AjustesImpViewState();
}

class _AjustesImpViewState extends State<AjustesImpView> {
  final _formAjuste = GlobalKey<FormState>();
  var txtNameBlue = TextEditingController();
  var txtVendedor = TextEditingController();
  var txtTitulo = TextEditingController();
  var txtFrase = TextEditingController();
  List<String> _columnasS = ['Valor', 'Premio'];
  String colm = 'Premio';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      txtTitulo.text = _prefs.getString('titulo_recibo') ?? 'CrazySales';
      txtNameBlue.text = _prefs.getString('namedevice') ?? '';
      txtVendedor.text = _prefs.getString('vendedor') ?? '';
      txtFrase.text = _prefs.getString('frase') ?? '';
      bool premio = _prefs.getBool('col_premio') ?? true;
      bool valor = _prefs.getBool('col_valor') ?? false;
      if (premio) {
        setState(() {
          colm = 'Premio';
        });
      } else if (valor) {
        setState(() {
          colm = 'Valor';
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
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
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: 7.5, top: 7.5),
                child: TextFormField(
                  validator: (vl) {
                    if (vl.length > 32) {
                      return "No puede superar los 32 caracteres";
                    } else if (vl.length == 0) {
                      return "No puede estar vacio";
                    } else {
                      return null;
                    }
                  },
                  controller: txtTitulo,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
                    labelText: "Título de Recibo",
                    hintText: "Título de Recibo",
                    fillColor: Colors.grey,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                          color: themeGlobal.primaryColor, width: 2.0),
                    ),
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: themeGlobal.accentColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                )),
            Divider(),
            Container(
                padding: EdgeInsets.only(bottom: 7.5, top: 7.5),
                child: TextFormField(
                  validator: (vl) {
                    if (vl.length > 32) {
                      return "No puede superar los 32 caracteres";
                    } else {
                      return null;
                    }
                  },
                  controller: txtVendedor,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
                    labelText: "Vendedor",
                    hintText: "Vendedor",
                    fillColor: Colors.grey,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                          color: themeGlobal.primaryColor, width: 2.0),
                    ),
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: themeGlobal.accentColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                )),
            Divider(),
            Container(
                padding: EdgeInsets.only(bottom: 7.5, top: 7.5),
                child: TextFormField(
                  controller: txtFrase,
                  validator: (vl) {
                    if (vl.length > 32) {
                      return "No puede superar los 32 caracteres";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
                    labelText: "Frase",
                    hintText: "Frase",
                    fillColor: Colors.grey,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                          color: themeGlobal.primaryColor, width: 2.0),
                    ),
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: themeGlobal.accentColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                )),
            Divider(),
            Container(
                padding: EdgeInsets.only(top: 7.5),
                child: InputGeneric(
                    controller: txtNameBlue,
                    enabled: false,
                    labelText: "Nombre de la impresora",
                    hintText: "Nombre de la impresora",
                    iconColor: themeGlobal.accentColor,
                    icon: Icons.arrow_forward)),
            Divider(),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Tipo de Impresion:",
                  ),
                  DropdownButton<String>(
                    value: colm,
                    onChanged: (String newValue) {
                      setState(() {
                        colm = newValue;
                      });
                    },
                    items: _columnasS.map((String c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              child: RaisedButton.icon(
                label: Text("Configurar impresora"),
                icon: Icon(Icons.bluetooth),
                textColor: Colors.white,
                color: themeGlobal.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0)),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) =>
                              DiscoveryPage()));

                  setState(() {
                    print(result);
                    txtNameBlue.text = result;
                  });
                },
              ),
            ),
            Container(
              child: RaisedButton.icon(
                  label: Text("Guardar Ajustes"),
                  icon: Icon(Icons.save),
                  textColor: Colors.white,
                  color: themeGlobal.accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                  onPressed: () async {
                    if (_formAjuste.currentState.validate()) {
                      SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                      _prefs.setString("titulo_recibo", txtTitulo.text);
                      _prefs.setString("vendedor", txtVendedor.text);
                      _prefs.setBool('col_premio', widget.premio);
                      _prefs.setBool('col_valor', widget.valor);
                      _prefs.setString('frase', txtFrase.text);

                      if (colm == 'Premio') {
                        _prefs.setBool('col_valor', false);
                        _prefs.setBool('col_premio', true);
                      } else if (colm == 'Valor') {
                        _prefs.setBool('col_valor', true);
                        _prefs.setBool('col_premio', false);
                      }
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
                  }),
            )
          ],
        ),
      ));

  Widget _titleAjuste() {
    return Text(
      "Ajustes Impresora",
      style: TextStyle(
          color: themeGlobal.primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold),
    );
  }
}
