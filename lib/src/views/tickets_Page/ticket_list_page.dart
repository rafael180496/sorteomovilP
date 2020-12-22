import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/design_bill.dart';
import 'package:sorteomovil/src/utils/native_methods.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/views/views.dart';
import 'package:sorteomovil/src/widget/widget.dart';

class TicketListView extends StatefulWidget with NavigationStates {
  final tarifa;

  TicketListView(this.tarifa);

  @override
  _TicketListViewState createState() => _TicketListViewState();
}

class _TicketListViewState extends State<TicketListView> {
  final TicketBloc ticketBloc = TicketBloc();
  final _formFilter = GlobalKey<FormState>();
  List<DataModel> clientes, sorteos, tarifario;
  var cliente = DataModel(id: -1, valor: valuesMsj["defaultCliente"]);
  var sorteo = DataModel(id: -1, valor: valuesMsj["defaultSorteo"]);
  ScrollController scrollController;
  TextEditingController _inputFieldDatemin = TextEditingController(text: "");
  TextEditingController _inputFieldDatemax = TextEditingController(text: "");
  TextEditingController _inputFieldSelectCliente =
      TextEditingController(text: "");
  TextEditingController _inputFieldSelectSorteo =
      TextEditingController(text: "");
  bool dialVisible = true;
  bool valid = true;
  String mac = " ";
  String _sorteoName = "";
  String titulo = "";
  String vendedor = "";
  String frase = "";
  bool premioColm = false;
  bool valorColm = true;
  bool inicioBlue = false;
  bool indPrint = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    ClienteModel.getData().then((items) {
      setState(() {
        clientes = items;
        if (clientes.isEmpty) {
          valid = false;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await warning(
                context, "cliente", NavigationEvents.ClientePageClickedEvent);
          });
        }
      });
    });
    SorteoModel.getData().then((items) {
      setState(() {
        sorteos = items;
      });
    });
    TarifarioModel.getData().then((value) {
      tarifario = value;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auxprefs = await SharedPreferences.getInstance();
      final auxmac =
          auxprefs.getString("mac") == null ? " " : auxprefs.getString("mac");
      final auxindprint =
          auxprefs.getBool("print") == null ? false : auxprefs.getBool("print");

      titulo = auxprefs.getString('titulo_recibo') ?? "CrazySales";
      vendedor = auxprefs.getString('vendedor') ?? "";
      frase = auxprefs.getString('frase') ?? "";

      premioColm = auxprefs.getBool('col_premio') ?? false;
      valorColm = auxprefs.getBool('col_valor') ?? true;

      indPrint = auxindprint;

      mac = auxmac;

      if (auxindprint) {
        if (mac == " ") {
          await warning(context, "impresor", NavigationEvents.ImpClickedEvent);
        } else {
          var activado = await NativeMethods.isEnabled();
          if (activado) {
            print(mac);
            NativeMethods.connectImp(mac);
            inicioBlue = true;
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
                  inicioBlue = true;
                },
                btnCancelOnPress: () {
                  inicioBlue = false;
                }).show();
          }
        }
      }
    });
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  _formFilterModal(BuildContext context) async {
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
        controller: _inputFieldSelectCliente,
        validator: (vl) {
          if (vl == valuesMsj["defaultCliente"] || vl.trim() == "") {
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
            cliente = data;
          });
        },
      ),
      InputGeneric(
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
            _inputFieldSelectSorteo.text = data.valor;
            sorteo = data;
          });
        },
      )
    ];

    formModal(context, _formFilter, preLoad: () async {
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
              await ticketBloc.getTickets(
                  fechaIni: vlini,
                  fechaFin: vlfin,
                  cliente: cliente.id,
                  sorteo: sorteo.id);
              Navigator.pop(context);
            },
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        floatingActionButton: buildSpeedDial(dialVisible, onRefresh: () async {
          await ticketBloc.getTickets();
        }, onNew: () async {
          navItem(context, NavigationEvents.TicketNewClickedEvent);
        }, onFilter: () async {
          _formFilterModal(context);
        }),
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.only(left: 5.0, right: 2.0, bottom: 2.0),
                child: getTicketsWidget())),
      ),
    );
  }

  Widget getTicketsWidget() {
    return StreamBuilder(
        stream: ticketBloc.tickets,
        builder: (BuildContext context, AsyncSnapshot<List<Tickets>> snapshot) {
          return getTicketCardWidget(snapshot);
        });
  }

  Widget getTicketCardWidget(AsyncSnapshot<List<Tickets>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              padding: EdgeInsets.only(top: 10, left: 15, right: 3),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, index) {
                Tickets data = snapshot.data[index];
                data.tarifas = widget.tarifa;
                data.tarifario = tarifario;
                return cardLoad(context, data);
              })
          : Container(
              child: Center(
              child: noItemsMessageWidget("Agrega una ticket"),
            ));
    } else {
      return Center(
        child: loadingDataSorteos(),
      );
    }
  }

  Widget cardLoad(BuildContext context, Tickets data) {
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
        title: AutoSizeText('${data.title()}',
            maxFontSize: 18,
            minFontSize: 1,
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
            DetLabel("Cliente", data.clienteObj.nombre),
            DetLabel("Sorteo", data.sorteoObj.getStr()),
            DetLabel("Fecha", data.fecha.toStr(inHr: true)),
            DetLabel("Monto", "${data.getTotal("pretotal").formatterRound()}"),
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
                          desc: 'Desea anular la ticket?',
                          btnOkOnPress: () async {
                            await ticketBloc.deleteTicket(data.id);
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
              Visibility(
                visible: indPrint,
                child: FlatButton(
                  splashColor: themeGlobal.accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  onPressed: () async {
                    if (inicioBlue) {
                      _sorteoName = data.sorteoObj.getStr();
                      imprimir(data);
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.print,
                        size: 33,
                        color: themeGlobal.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              FlatButton(
                splashColor: themeGlobal.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetView(ticket: data),
                    ),
                  );
                },
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.receipt,
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

  @override
  void dispose() {
    if (mac != " ") {
      NativeMethods.destroyImp();
    }
    super.dispose();
  }

  Widget loadingDataSorteos() {
    ticketBloc.getTickets();
    return loadingData();
  }

  void imprimir(Tickets ticket) async {
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
