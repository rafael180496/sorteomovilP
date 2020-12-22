import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

ProgressDialog pr;

class LicenseSMPage extends StatefulWidget {
  static GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool unautorized;
  const LicenseSMPage(this.unautorized);

  @override
  _LicenseSMPageState createState() => _LicenseSMPageState();
}

class _LicenseSMPageState extends State<LicenseSMPage> {
  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    if (widget.unautorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _dialogUnauthorized(context);
      });
    }
  }

  getPreferences() async => SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    ConnectionStatus.internal().checkConnection().then((value) {
      setState(() {
        isOnline = value;
      });
    });

    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    pr = ProgressDialog(context);
    pr.style(
        message: 'Por Favor espere...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Scaffold(
      key: LicenseSMPage._scaffoldKey,
      body: Container(
          height: queryData.size.height,
          color: themeGlobal.primaryColor,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: 40,
                          child: Image.asset(
                            paramValues["logofile2"],
                            height: 64,
                            width: 64,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            valuesMsj['appname'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 24),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: ButtonTheme(
                        minWidth: queryData.size.width - 20,
                        height: 54.0,
                        buttonColor: themeGlobal.accentColor,
                        child: RaisedButton(
                            textColor: Colors.white,
                            onPressed: () {
                              _dialogContactenos(context);
                            },
                            child: Text("Contactenos"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0))),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: ButtonTheme(
                        minWidth: queryData.size.width - 20,
                        height: 54.0,
                        child: OutlineButton(
                            textColor: Colors.white,
                            color: Colors.white,
                            onPressed: () {
                              if (isOnline) {
                                _dialogKey(context);
                              } else {
                                _showsnackBar(
                                    text: 'No posee conexion a Internet!');
                              }
                            },
                            child: Text("Activacion de licencia"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.white))),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  _dialogKey(BuildContext context) async {
    dialogCustom(
        content: _formKey(),
        context: context,
        titulo: "Activación",
        closeFunction: () {
          _clearDialog();
        });
  }

  _dialogUnauthorized(BuildContext context) async {
    await dialogCustom(
        content: Column(
          children: <Widget>[
            textMultiline(
                contenido:
                    "Se ha desactivado la licencia en este dispositivo y se han perdido los datos.",
                fontSize: 13,
                lines: 3),
            AccionBtn(
                colorText: Colors.green,
                textBtn: "Continuar",
                icon: Icons.arrow_forward,
                onPressed: () => _clearDialog())
          ],
        ),
        context: context,
        titulo: "Activación",
        closeFunction: () {
          _clearDialog();
        });
  }

  _dialogContactenos(BuildContext context) async {
    dialogCustom(
        content: _contactenos(),
        context: context,
        titulo: "Comprar",
        closeFunction: () {
          _clearDialog();
        });
  }

  Widget lineaFlexible(String titulo, String dato) {
    return Padding(
        padding: EdgeInsets.only(top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(
                width: double.infinity,
                child: Text(
                  titulo,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                  width: double.infinity,
                  child: Text(
                    dato,
                    style: TextStyle(fontSize: 14),
                  )),
            )
          ],
        ));
  }

  Widget _formKey() {
    final _formSorteo = GlobalKey<FormState>();
    String _key = "";
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(bottom: 20)),
        Form(
          key: _formSorteo,
          child: InputGeneric(
            onSaved: (value) => _key = value,
            initialValue: _key,
            hintText: "Llave de Activación",
            labelText: "Llave de Activación",
          ),
        ),
        Divider(),
        Wrap(
          spacing: 8,
          children: <Widget>[
            AccionBtn(
              colorText: Colors.red,
              onPressed: () => _clearDialog(),
              textBtn: "Cancelar",
              icon: Icons.close,
            ),
            AccionBtn(
              colorText: Colors.green,
              onPressed: () {
                _clearDialog();
                pr.show();
                _formSorteo.currentState.save();
                _obtenerLicencia(context, _key);
              },
              textBtn: "Aplicar",
              icon: Icons.check,
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactenos() {
    final storeRef = Firestore.instance.collection("parametros");
    dynamic _values;
    return StreamBuilder(
        stream: storeRef.document("vendedor").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _values = snapshot.data;
          }
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Contáctenos",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              lineaFlexible("Correo:",
                  "${_values == null ? "Cargando..." : _values['email']}"),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Divider(),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  AccionBtn(
                    colorText: Colors.red,
                    textBtn: "Cancelar",
                    icon: Icons.close,
                    onPressed: () => _clearDialog(),
                  ),
                  AccionBtn(
                    onPressed: () => launchEmail(
                        scaffoldKey: LicenseSMPage._scaffoldKey,
                        context: context,
                        para: "${_values['email']}",
                        asunto: "${_values['asuntoCorreo']}",
                        body: "${_values['msgCorreo']}"),
                    colorText: Colors.black,
                    icon: Icons.email,
                    textBtn: "Correo",
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  AccionBtn(
                    onPressed: () => launchWhatsApp(
                        scaffoldKey: LicenseSMPage._scaffoldKey,
                        context: context,
                        phone: "${_values['celular']}",
                        message: "${_values['msgCorreo']}"),
                    colorText: Colors.green,
                    icon: FontAwesomeIcons.whatsapp,
                    textBtn: "WhatsApp",
                  ),
                ],
              )
            ],
          );
        });
  }

  Widget _advertenciaIdMovil() => Column(
        children: <Widget>[
          textMultiline(
              contenido:
                  "Se ha detectado que la llave de activación que ha sido utilizada para ingresar, pudo ser usada en otro dispositivo o en el actual.",
              fontSize: 13,
              lines: 5),
          textMultiline(
              contenido:
                  "Si se está usando en otro dispositivo, se perderán todos los datos, esto se debe a que solo se puede mantener un solo móvil activado.",
              fontSize: 13,
              lines: 4),
          textMultiline(
              contenido:
                  "En caso de que el párrafo anterior no sea su caso, puede dar continuar.",
              fontSize: 13,
              lines: 2),
          Wrap(
            spacing: 8,
            children: <Widget>[
              AccionBtn(
                colorText: Colors.red,
                onPressed: () {
                  License.internal().cleanLicense();
                  _clearDialog();
                },
                textBtn: "Cancelar",
                icon: Icons.close,
              ),
              AccionBtn(
                  colorText: Colors.green,
                  onPressed: () => _addNewIdMovil(),
                  textBtn: "Continuar",
                  icon: Icons.arrow_forward),
            ],
          ),
        ],
      );

  _clearDialog() => Navigator.of(context).popUntil((route) => route.isFirst);

  _showsnackBar({@required text}) =>
      LicenseSMPage._scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(text),
      ));

  _addNewIdMovil() async {
    await License.internal().addKeyIdMovil();
    pr.hide();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('side', (Route<dynamic> route) => false);
  }

  void _obtenerLicencia(BuildContext context, String _key) async {
    bool success = await License.internal().initLicense(key: _key);
    if (success) {
      await License().actualizar();
      success = await License.internal().vencimiento();
      if (success) {
        success = await License.internal().validateKeyIdMovil();
        if (success) {
          _addNewIdMovil();
        } else {
          pr.hide();
          dialogCustom(
              content: _advertenciaIdMovil(),
              context: context,
              titulo: "Advertencia",
              closeFunction: () {
                License.internal().cleanLicense();
                _clearDialog();
              });
        }
      } else {
        pr.hide();
        _showsnackBar(text: 'licencia expirada!');
      }
    } else {
      pr.hide();
      _showsnackBar(text: 'Licencia no valida!');
    }
  }
}
