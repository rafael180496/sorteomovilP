import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/design_bill.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/utils/native_methods.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';

class TicketNewView extends StatefulWidget with NavigationStates {
  final tipo;
  final tarifa;

  TicketNewView(this.tipo, this.tarifa);

  @override
  _TicketNewViewState createState() => _TicketNewViewState();
}

class _TicketNewViewState extends State<TicketNewView> {
  final _formTicket = GlobalKey<FormState>();
  final _formNumero = GlobalKey<FormState>();
  final GlobalKey<ExpansionTileCardState> cardticket = new GlobalKey();
  final lengNumero = 2;
  final TicketBloc ticketBloc = TicketBloc();
  SharedPreferences _prefs;
  bool avisovenc = false;
  int dias = 0;
  double valor = 0.00;
  int descuento = 0;
  int tipoValor = 1;
  int inselect = 0;
  bool inFijo = false;
  FocusNode _focusNumero = FocusNode();
  FocusNode _focusCantidad = FocusNode();
  ScrollController scrollController;
  var ticket = Tickets();
  TextEditingController _inputFieldValor = TextEditingController(text: "");
  TextEditingController _inputFieldNumero = TextEditingController(text: "");
  TextEditingController _inputFieldSelectCliente =
      TextEditingController(text: "");
  TextEditingController _inputFieldSelectSorteo =
      TextEditingController(text: "");
  List<DataModel> clientes, sorteos, tarifario;
  var cliente = DataModel(id: -1, valor: valuesMsj["defaultCliente"]);
  var sorteo = DataModel(id: -1, valor: valuesMsj["defaultSorteo"]);
  bool valid = true;
  bool changeTip = false;
  String mac = " ";
  String _sorteoName = "";
  String titulo = "";
  String vendedor = "";
  String frase = "";
  bool premioColm = false;
  bool valorColm = true;
  bool inicioBlue = false;
  bool indPrint = false;
  bool blue = true;

  void resetTicket() {
    setState(() {
      inFijo = false;
      ticket.id = null;
      ticket.detalle = [];
      _inputFieldNumero.text = "";
      _inputFieldValor.text = "";
      FocusScope.of(context).requestFocus(_focusNumero);
      inselect = 1;
    });
  }

  warningVenc() async {
    await AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Advertencia',
      desc: 'La licencia esta a $dias dias por vencer.',
      btnOkText: "Ok",
      btnOkColor: themeGlobal.accentColor,
      btnOkOnPress: () {
        _prefs.setBool("avisovenc", false);
      },
    ).show();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auxprefs = await SharedPreferences.getInstance();
      final auxavisovenc = auxprefs.getBool("avisovenc");
      final auxdias = auxprefs.getInt("diferenciavenc");
      final auxmac =
          auxprefs.getString("mac") == null ? " " : auxprefs.getString("mac");
      final auxindprint =
          auxprefs.getBool("print") == null ? false : auxprefs.getBool("print");

      titulo = auxprefs.getString('titulo_recibo') ?? "CrazySales";
      vendedor = auxprefs.getString('vendedor') ?? "";
      frase = auxprefs.getString('frase') ?? "";

      premioColm = auxprefs.getBool('col_premio') ?? false;
      valorColm = auxprefs.getBool('col_valor') ?? true;

      final auxclientes = await ClienteModel.getData();
      final auxsorteos = await SorteoModel.getData();
      final auxtarifarios = await TarifarioModel.getData();
      setState(() {
        _prefs = auxprefs;
        avisovenc = auxavisovenc;
        dias = auxdias;
        clientes = auxclientes;
        sorteos = auxsorteos;
        tarifario = auxtarifarios;
        mac = auxmac;
      });

      if (avisovenc) {
        await warningVenc();
      }
      if (clientes.isEmpty) {
        setState(() {
          valid = false;
        });

        await warning(
            context, "cliente", NavigationEvents.ClientePageClickedEvent);
      }
      if (sorteos.isEmpty && valid) {
        setState(() {
          valid = false;
        });
        await warning(
            context, "sorteo", NavigationEvents.SorteoPageClickedEvent);
      }

      if (widget.tarifa == Tarifas.ESPECIAL) {
        if (tarifario.isEmpty && valid) {
          setState(() {
            valid = false;
          });
          await warning(
              context, "tarifas", NavigationEvents.TarifarioClickedEvent);
        }
      }

      indPrint = auxindprint;

      if (auxindprint) {
        if (mac == " " && valid) {
          setState(() {
            valid = false;
          });
          await warning(context, "impresor", NavigationEvents.ImpClickedEvent);
        } else {
          var activado = await NativeMethods.isEnabled();
          if (activado) {
            print(mac);
            setState(() {
              inicioBlue = false;
              blue = true;
            });
            NativeMethods.connectImp(mac);
          } else {
            AwesomeDialog(
                dismissOnTouchOutside: false,
                context: context,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: 'Advertencia',
                desc: 'Desea Activar el Bluetooth?',
                btnOkText: "Ok",
                btnOkColor: themeGlobal.accentColor,
                btnOkOnPress: () {
                  NativeMethods.turnOnAsync();
                  setState(() {
                    inicioBlue = true;
                    blue = true;
                  });
                },
                btnCancelOnPress: () {
                  inicioBlue = false;
                  blue = false;
                }).show();
          }
        }
      }
    });

    ticket.fecha = DateTime.now();

    ticket.detalle = [];
  }

  @override
  void dispose() {
    if (mac != " ") {
      NativeMethods.destroyImp();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!changeTip) {
      tipoValor = widget.tipo == null ? 1 : widget.tipo;
      changeTip = true;
    }

    return WillPopScope(
        child: Scaffold(
            body: SafeArea(
                child: Form(
                    key: _formTicket,
                    child: Container(
                        padding: EdgeInsets.only(top: 12, left: 7, right: 6),
                        width: double.maxFinite,
                        child: ListView(
                          children: <Widget>[
                            _cardInfoTicket(context),
                            _cardListNums(context),
                            Form(
                              child: _formPart2(),
                              key: _formNumero,
                            )
                          ],
                        ))))),
        onWillPop: () => showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: Column(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 55,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'Advertencia',
                      style: TextStyle(
                          color: themeGlobal.primaryColorDark, fontSize: 25),
                    )
                  ],
                ),
                content: Text('¿Seguro que desea salir de la aplicacion?',
                    style: TextStyle(fontSize: 22)),
                actionsOverflowButtonSpacing: 3.00,
                actions: [
                  AccionBtn(
                    colorText: Colors.red,
                    textBtn: "Salir",
                    icon: Icons.exit_to_app,
                    onPressed: () => Navigator.pop(c, true),
                  ),
                  AccionBtn(
                    colorText: themeGlobal.accentColor,
                    textBtn: "Cancelar",
                    icon: Icons.cancel,
                    onPressed: () => Navigator.pop(c, false),
                  ),
                ],
              ),
            ));
  }

  Widget _infoExtra(DataModel cliente, DataModel sorteo) {
    final cli = (cliente.data as Cliente);
    final sr = (sorteo.data as Sorteo);
    setState(() {
      valor = sr == null ? 0 : sr.valor;
      descuento = cli == null ? 0 : cli.descuento;
    });
    return Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 30, right: 0),
            child: Text('Sorteo:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        Container(
            padding: EdgeInsets.only(left: 30, right: 0),
            child: Text('$valor', style: TextStyle(fontSize: 15))),
      ],
    );
  }

  _removeIndex(int index) {
    setState(() {
      ticket.detalle.removeAt(index);
    });
  }

  _addIndex(TicketsDet data) {
    setState(() {
      ticket.detalle.add(data);
    });
  }

  Widget _listNum() {
    return ticket.detalle.isEmpty
        ? Center(
            child: noItemsMessageWidget("Agrega un numero"),
          )
        : ListView.builder(
            itemCount: ticket.detalle.length,
            itemBuilder: (_, i) => cardNum(
                data: ticket.detalle[i],
                onPressed: () {
                  _removeIndex(i);
                }),
          );
  }

  Widget _formPart2() {
    final vlTextInput = tipoValor == 0 ? "Cantidad" : "Premio";
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15, left: 8),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: InputGeneric(
                    controller: _inputFieldNumero,
                    readOnly: true,
                    labelText: "Numero",
                    focusNode: _focusNumero,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Ingrese un numero";
                      }
                      var valueParse = int.parse(value);
                      return valueParse < 0 ? "Ingrese un numero" : null;
                    },
                    hintText: "numero",
                    range: 0,
                    maxLength: lengNumero,
                    tipo: TipoInput.Digit,
                    border: false,
                    onTap: () {
                      setState(() {
                        inselect = 1;
                      });
                    },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: InputGeneric(
                    focusNode: _focusCantidad,
                    enabled: inFijo ? false : true,
                    controller: _inputFieldValor,
                    readOnly: true,
                    labelText: vlTextInput,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Ingrese un $vlTextInput";
                      }
                      return null;
                    },
                    hintText: "$vlTextInput",
                    range: 0,
                    tipo: TipoInput.Digit,
                    border: false,
                    onTap: () {
                      setState(() {
                        inselect = 2;
                      });
                    },
                  ),
                ),
                Flexible(
                    flex: 2,
                    child: CheckboxListTile(
                      activeColor: themeGlobal.primaryColor,
                      contentPadding: EdgeInsets.only(left: 0, right: 7),
                      subtitle: btnBorrar(),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: inFijo,
                      onChanged: (vl) {
                        setState(() {
                          inFijo = vl;
                          if (inFijo) {
                            inselect = 1;
                            _inputFieldValor.text =
                                _inputFieldValor.text.trim() == ""
                                    ? "1"
                                    : _inputFieldValor.text;
                          } else {
                            _cleanInput();
                          }
                        });
                      },
                    )),
              ],
            ),
          ),
          _customKeyboard()
        ],
      ),
    );
  }

  _cleanInput() {
    setState(() {
      inselect = 1;
      inFijo = false;
      FocusScope.of(context).requestFocus(_focusNumero);
      _inputFieldNumero.text = "";
      _inputFieldValor.text = "";
    });
  }

  Widget _cardInfoTicket(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 0),
      child: ExpansionTileCard(
        initiallyExpanded: true,
        key: cardticket,
        borderRadius: BorderRadius.circular(20),
        elevation: 10,
        title: ListTile(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Icon(
                Icons.receipt,
                size: 18,
                color: themeGlobal.primaryColor,
              ),
            ),
            Flexible(
                flex: 5,
                child: AutoSizeText("Agregando una nueva ticket",
                    minFontSize: 5,
                    maxLines: 1,
                    maxFontSize: 20,
                    style: TextStyle(
                        fontSize: 20, color: themeGlobal.primaryColor)))
          ],
        )),
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(children: <Widget>[
                Flexible(
                  child: InputGeneric(
                    enableInteractiveSelection: true,
                    controller: _inputFieldSelectCliente,
                    validator: (vl) {
                      if (vl == valuesMsj["defaultCliente"] ||
                          vl.trim() == "") {
                        return "Ingrese un cliente";
                      }
                      return null;
                    },
                    labelText: "Cliente",
                    hintText: "ingrese un cliente",
                    items: clientes,
                    item: cliente,
                    tipo: TipoInput.Select,
                    labelSelect: "Seleccione un cliente",
                    border: false,
                    onData: (data) {
                      setState(() {
                        _inputFieldSelectCliente.text = data.valor;
                        ticket.cliente = data.id;
                        cliente = data;
                      });
                    },
                  ),
                ),
                Flexible(
                    child: InputGeneric(
                  enableInteractiveSelection: true,
                  controller: _inputFieldSelectSorteo,
                  validator: (vl) {
                    if (vl == valuesMsj["defaultSorteo"] || vl.trim() == "") {
                      return "Ingrese un Sorteo";
                    }
                    return null;
                  },
                  labelText: "Sorteo",
                  hintText: "ingrese un Sorteo",
                  items: sorteos,
                  item: sorteo,
                  tipo: TipoInput.Select,
                  labelSelect: "Seleccione un Sorteo",
                  border: false,
                  onData: (data) {
                    setState(() {
                      _sorteoName = "${data.valor}";
                      _inputFieldSelectSorteo.text = data.valor;
                      ticket.sorteo = data.id;
                      sorteo = data;
                    });
                  },
                ))
              ])),
          Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 4,
                    child: InputGeneric(
                      onToggle: (vl) {
                        setState(() {
                          tipoValor = vl;
                          print(tipoValor);
                        });
                      },
                      minWidth: 68.0,
                      cornerRadius: 15,
                      initialLabelIndex: tipoValor,
                      switchTitle: "Tipo",
                      switchTitleColor: themeGlobal.primaryColorDark,
                      switchTitleSize: 15,
                      labelOn: "Valor",
                      labelOff: "Premio",
                      onColor: themeGlobal.accentColor,
                      offColor: themeGlobal.accentColor,
                      tipo: TipoInput.Switch,
                    ),
                  ),
                  Flexible(flex: 2, child: _infoExtra(cliente, sorteo))
                ],
              )),
        ],
      ),
    );
  }

  Widget _cardListNums(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 0),
      child: ExpansionTileCard(
        borderRadius: BorderRadius.circular(20),
        elevation: 10,
        trailing: Badge(
          animationType: BadgeAnimationType.slide,
          badgeColor: themeGlobal.accentColor,
          badgeContent: Text(
            '${ticket.detalle.length}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          child: Icon(
            Icons.confirmation_number,
            color: themeGlobal.primaryColor,
          ),
        ),
        title: Text('Lista de numeros',
            style: TextStyle(
                color: themeGlobal.primaryColorDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(right: 4, bottom: 10, top: 0, left: 8),
              height: 270,
              child: _listNum()),
          Divider(),
          totales(ticket),
        ],
      ),
    );
  }

  bool _validateform() {
    var resp = _formTicket.currentState.validate() &&
        ticket.cliente >= 0 &&
        ticket.sorteo >= 0;
    if (!resp) {
      cardticket.currentState.expand();
    }
    return resp;
  }

  Widget _customKeyboard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: boton('7'),
            ),
            Flexible(
              flex: 1,
              child: boton('8'),
            ),
            Flexible(
              flex: 1,
              child: boton('9'),
            ),
            Flexible(
              flex: 1,
              child: boton('0'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: boton('4'),
            ),
            Flexible(
              flex: 1,
              child: boton('5'),
            ),
            Flexible(
              flex: 1,
              child: boton('6'),
            ),
            Flexible(
              flex: 1,
              child: boton('00'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: boton('1'),
            ),
            Flexible(
              flex: 1,
              child: boton('2'),
            ),
            Flexible(
              flex: 1,
              child: boton('3'),
            ),
            Flexible(
              flex: 1,
              child: boton('-'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: FlatButton(
                  onPressed: () async {
                    if (_validateform()) {
                      if (ticket.detalle.isNotEmpty) {
                        try {
                          await ticketBloc.addTicket(ticket);

                          print("$indPrint , $inicioBlue");
                          if (indPrint && blue) {
                            AwesomeDialog(
                              dismissOnTouchOutside: false,
                              context: context,
                              dialogType: DialogType.SUCCES,
                              animType: AnimType.BOTTOMSLIDE,
                              title: 'Imprimir',
                              desc: 'Desea imprimir el Ticket?',
                              btnCancelColor: themeGlobal.primaryColor,
                              btnCancelText: "Si",
                              btnCancelOnPress: () {
                                imprimir();
                                AwesomeDialog(
                                  dismissOnTouchOutside: false,
                                  context: context,
                                  dialogType: DialogType.SUCCES,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Guardado',
                                  desc: 'La ticket fue creada.',
                                  btnOkText: "Lista",
                                  btnOkColor: themeGlobal.primaryColor,
                                  btnOkOnPress: () {
                                    navItem(
                                        context,
                                        NavigationEvents
                                            .TicketListClickedEvent);
                                  },
                                  btnCancelColor: themeGlobal.accentColor,
                                  btnCancelText: "Nuevo",
                                  btnCancelOnPress: () {
                                    resetTicket();
                                  },
                                ).show();
                              },
                              btnOkText: "No",
                              btnOkColor: themeGlobal.accentColor,
                              btnOkOnPress: () {
                                AwesomeDialog(
                                  dismissOnTouchOutside: false,
                                  context: context,
                                  dialogType: DialogType.SUCCES,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Guardado',
                                  desc: 'La ticket fue creada.',
                                  btnOkText: "Lista",
                                  btnOkColor: themeGlobal.primaryColor,
                                  btnOkOnPress: () {
                                    navItem(
                                        context,
                                        NavigationEvents
                                            .TicketListClickedEvent);
                                  },
                                  btnCancelColor: themeGlobal.accentColor,
                                  btnCancelText: "Nuevo",
                                  btnCancelOnPress: () {
                                    resetTicket();
                                  },
                                ).show();
                              },
                            ).show();
                          } else {
                            AwesomeDialog(
                              dismissOnTouchOutside: false,
                              context: context,
                              dialogType: DialogType.SUCCES,
                              animType: AnimType.BOTTOMSLIDE,
                              title: 'Guardado',
                              desc: 'La ticket fue creada.',
                              btnOkText: "Lista",
                              btnOkColor: themeGlobal.primaryColor,
                              btnOkOnPress: () {
                                navItem(context,
                                    NavigationEvents.TicketListClickedEvent);
                              },
                              btnCancelColor: themeGlobal.accentColor,
                              btnCancelText: "Nuevo",
                              btnCancelOnPress: () {
                                resetTicket();
                              },
                            ).show();
                          }
                        } catch (e) {
                          print(e);
                          AwesomeDialog(
                            dismissOnTouchOutside: false,
                            context: context,
                            dialogType: DialogType.ERROR,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'Error',
                            desc: 'Ocurrio un problema al ingresar una ticket.',
                            btnOkOnPress: () {},
                          ).show();
                        }
                      } else {
                        AwesomeDialog(
                          dismissOnTouchOutside: false,
                          context: context,
                          dialogType: DialogType.WARNING,
                          animType: AnimType.BOTTOMSLIDE,
                          title: 'Advertencia',
                          desc: 'Por favor ingrese un numero o cancele.',
                          btnOkOnPress: () {},
                        ).show();
                      }
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Icon(
                          Icons.save,
                          color: themeGlobal.primaryColor,
                        ),
                        flex: 2,
                      ),
                      Flexible(
                        child: AutoSizeText(
                          "Guardar",
                          minFontSize: 5,
                          maxFontSize: 17,
                          maxLines: 1,
                          style: TextStyle(
                              color: themeGlobal.primaryColor, fontSize: 17),
                        ),
                        flex: 4,
                      )
                    ],
                  )),
            ),
            Flexible(
              child: btnAccs("", themeGlobal.accentColor, () async {
                if (_validateform() && _formNumero.currentState.validate()) {
                  var ticketdet = TicketsDet(
                      cant: double.parse(_inputFieldValor.text),
                      desc: descuento,
                      valor: valor,
                      numero: int.parse(_inputFieldNumero.text),
                      ticket: -1,
                      sorteo: ticket.sorteo);

                  if (tipoValor == 1) {
                    ticketdet.cant =
                        (ticketdet.cant.toDouble() * ticketdet.valor) /
                            paramValues["vlcalc"];
                  }

                  if (widget.tarifa == Tarifas.ESPECIAL) {
                    ticketdet.tarifas = widget.tarifa;
                    if (tipoValor == 0) {
                      var values = _getValueTarifarios(
                          int.parse(_inputFieldValor.text), 0);
                      ticketdet.valorTarifa = values[0];
                      ticketdet.premioTarifa = values[1];
                    } else {
                      var values = _getValueTarifarios(
                          int.parse(_inputFieldValor.text), 1);
                      ticketdet.valorTarifa = values[0];
                      ticketdet.premioTarifa = values[1];
                      ticketdet.cant = values[0].toDouble();
                    }
                  }

                  var exist = true;
                  if ((ticketdet.premioTarifa == 0 ||
                          ticketdet.valorTarifa == 0) &&
                      widget.tarifa == Tarifas.ESPECIAL) {
                    exist = false;
                    AwesomeDialog(
                      dismissOnTouchOutside: false,
                      context: context,
                      dialogType: DialogType.ERROR,
                      animType: AnimType.BOTTOMSLIDE,
                      title: 'Error',
                      desc:
                          'La cantidad o premio que ha ingresado no existe en el tarifario.',
                      btnOkOnPress: () {
                        setState(() {
                          inselect = 2;
                          FocusScope.of(context).requestFocus(_focusCantidad);
                          if (!inFijo) {
                            _inputFieldValor.text = "";
                          }
                        });
                      },
                    ).show();
                  }

                  if (exist) {
                    _addIndex(ticketdet);

                    if (indPrint) {
                      if (inicioBlue) {
                        NativeMethods.connectImp(mac);
                        inicioBlue = false;
                        blue = true;
                      }
                    }
                    setState(() {
                      inselect = 1;
                      FocusScope.of(context).requestFocus(_focusNumero);
                      _inputFieldNumero.text = "";
                      if (!inFijo) {
                        _inputFieldValor.text = "";
                      }
                    });
                  }
                }
              }, icon: Icons.add, iconColor: Colors.white),
              flex: 2,
            ),
            Flexible(
              child: FlatButton(
                  onPressed: () {
                    AwesomeDialog(
                      dismissOnTouchOutside: false,
                      context: context,
                      dialogType: DialogType.WARNING,
                      animType: AnimType.BOTTOMSLIDE,
                      title: 'Advertencia',
                      desc: 'Quiere regresar o salir?',
                      btnOkText: "Salir",
                      btnOkColor: themeGlobal.primaryColor,
                      btnOkOnPress: () {
                        navItem(
                            context, NavigationEvents.TicketListClickedEvent);
                      },
                      btnCancelColor: themeGlobal.accentColor,
                      btnCancelText: "Reintentar",
                      btnCancelOnPress: () {
                        resetTicket();
                      },
                    ).show();
                  },
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      Flexible(
                          flex: 4,
                          child: AutoSizeText(
                            "Cancelar",
                            minFontSize: 5,
                            maxFontSize: 17,
                            maxLines: 1,
                            style: TextStyle(color: Colors.red, fontSize: 17),
                          ))
                    ],
                  )),
              flex: 2,
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        )
      ],
    );
  }

  nextTextbox() {
    if (!inFijo) {
      FocusScope.of(context).nextFocus();
      inselect = 2;
    }
  }

  Widget boton(btntxt, {enabled: true}) {
    return btnAccs(btntxt, Colors.white, () {
      setState(() {
        switch (inselect) {
          case 1:
            if (_inputFieldNumero.text.length < lengNumero - 1) {
              _inputFieldNumero.text = _inputFieldNumero.text + btntxt;
              if (btntxt == '00') {
                nextTextbox();
              }
            } else if (_inputFieldNumero.text.length < lengNumero) {
              _inputFieldNumero.text = _inputFieldNumero.text + btntxt;
              nextTextbox();
            }
            if (_inputFieldNumero.text.length >= 3) {
              _inputFieldNumero.text = _inputFieldNumero.text
                  .substring(0, _inputFieldNumero.text.length - 1);
            }
            break;
          case 2:
            _inputFieldValor.text = _inputFieldValor.text + btntxt;
            break;
          default:
        }
      });
    }, enabled: enabled);
  }

  Widget btnBorrar() {
    return FlatButton(
      splashColor: themeGlobal.primaryColorDark,
      padding: EdgeInsets.only(right: 0),
      color: Colors.red[600],
      onLongPress: () {
        _cleanInput();
      },
      onPressed: () {
        setState(() {
          setState(() {
            switch (inselect) {
              case 1:
                _inputFieldNumero.text = (_inputFieldNumero.text.length > 0)
                    ? (_inputFieldNumero.text
                        .substring(0, _inputFieldNumero.text.length - 1))
                    : "";
                break;
              case 2:
                _inputFieldValor.text = (_inputFieldValor.text.length > 0)
                    ? (_inputFieldValor.text
                        .substring(0, _inputFieldValor.text.length - 1))
                    : "";
                break;
              default:
            }
          });
        });
      },
      child: Icon(
        Icons.arrow_back,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  List _getValueTarifarios(int parse, int option) {
    int premio = 0;
    int valor = 0;
    for (var tarifa in tarifario) {
      print("[$parse] == [${tarifa.data.valor}]");
      if (option == 0) {
        if (parse == tarifa.data.valor) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      } else {
        if (parse == tarifa.data.premio) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      }
    }
    print("_getPremio: $premio");
    return [valor, premio];
  }

  void imprimir() async {
    //NativeMethods.turnOn();
    final auxprefs = await SharedPreferences.getInstance();
    var _tiraje = auxprefs.getInt(_sorteoName) ?? 1;
    String strTiraje = "T$_tiraje";
    _tiraje = _tiraje + 1;
    auxprefs.setInt(_sorteoName, _tiraje);
    int columna = 0;
    if (premioColm && !valorColm) {
      columna = 1;
    } else {
      columna = 0;
    }

    String recibo = await formarFactura(
        titulo, _sorteoName, ticket, columna, vendedor, strTiraje, frase);
    print(recibo);
    await NativeMethods.imprimir(recibo);
  }
}
