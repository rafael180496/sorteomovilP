import 'package:flutter/material.dart';

Widget loadingData() => Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Cargando...",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );

Widget noItemsMessageWidget(String titulo) => Container(
      child: Text(
        titulo,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
    );

class DetLabel extends StatelessWidget {
  final String atr;
  final Key key;
  final double size;
  final String vl;
  final bool ship;
  final Color textColor;
  final Color shipColor;
  final MainAxisAlignment mainAxisAlignment;
  DetLabel(this.atr, this.vl,
      {this.key,
      this.size: 16,
      this.ship: false,
      this.shipColor: Colors.grey,
      this.textColor: Colors.black,
      this.mainAxisAlignment: MainAxisAlignment.center});
  @override
  Widget build(BuildContext context) {
    final valor = ship
        ? Chip(
            backgroundColor: shipColor,
            padding: EdgeInsets.all(0),
            label:
                Text(vl, style: TextStyle(color: Colors.white, fontSize: size)),
          )
        : Text(vl, style: TextStyle(color: textColor, fontSize: size));

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: <Widget>[
        Text('$atr: ',
            style: TextStyle(
                color: textColor, fontSize: size, fontWeight: FontWeight.bold)),
        valor
      ],
    );
  }
}

Widget detLabelList(List<DetLabel> data) => Column(
      children: data,
    );

Widget textMultiline(
    {@required String contenido, double fontSize: 14, int lines: 1}) {
  return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(
        contenido,
        textAlign: TextAlign.justify,
        overflow: TextOverflow.clip,
        maxLines: lines,
        textDirection: TextDirection.ltr,
        style: TextStyle(fontSize: fontSize),
      ));
}
