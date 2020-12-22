import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';

class TicketDetView extends StatefulWidget with NavigationStates {
  final Key key;
  final Tickets ticket;
  TicketDetView({this.key, @required this.ticket});
  @override
  _TicketDetViewState createState() => _TicketDetViewState();
}

class _TicketDetViewState extends State<TicketDetView> {
  ScrollController scrollController;
  bool dialVisible = true;

  Widget _title() => Text('Nro.${widget.ticket.id} Vendido',
      style: TextStyle(
          fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold));
  Widget _descrip() {
    final nombre =
        "Cliente: ${widget.ticket.clienteObj.nombre} - ${widget.ticket.clienteObj.descuento}";
    final fecha = "Fecha: ${widget.ticket.fecha.toStr(inHr: true)}";
    final sorteo =
        "Sorteo: ${widget.ticket.sorteoObj.getStr()} - ${widget.ticket.sorteoObj.valor} C\$";
    return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          children: <Widget>[
            Text(sorteo, style: TextStyle(fontSize: 14.0)),
            Text(nombre, style: TextStyle(fontSize: 14.0)),
            Text(fecha, style: TextStyle(fontSize: 14.0)),
          ],
        ));
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildSpeedDial(dialVisible, onCancel: () {
        Navigator.pop(context);
      }),
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: Clipper(inSencond: false),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 250.0,
              decoration: BoxDecoration(
                color: themeGlobal.primaryColor,
              ),
            ),
          ),
          ClipPath(
            clipper: Clipper(),
            child: Container(
              width: MediaQuery.of(context).size.width - 230.0,
              height: MediaQuery.of(context).size.height - 250.0,
              decoration: BoxDecoration(
                color: themeGlobal.accentColor,
              ),
            ),
          ),
          Center(
            child: Material(
              elevation: 30.0,
              color: Colors.white12,
              borderRadius: BorderRadius.circular(18.0),
              child: Container(
                width: 320.0,
                height: 330.0,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(18.0)),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: ClipPath(
                  clipper: ZigZagClipper(),
                  child: Container(
                    width: 330.0,
                    height: 550.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.0)),
                    child: Column(
                      children: <Widget>[
                        imgTicket(),
                        _title(),
                        _descrip(),
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Container(
                              width: 300.0,
                              height: 220.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Colors.grey, width: 1.0)),
                              child: ListView.builder(
                                  itemCount: widget.ticket.detalle.length,
                                  itemBuilder: (_, i) =>
                                      itemsNums(widget.ticket.detalle[i]))),
                        ),
                        totalesTicket(widget.ticket)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
