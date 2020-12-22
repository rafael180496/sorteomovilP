import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/models/TicketDet.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/config.dart';
import 'package:sorteomovil/src/utils/utils.dart';

Widget totales(Tickets data, {String money: "C\$"}) {
  final pretotal = data.getTotal("pretotal").formatterRound();
  final total = data.getTotal("premio").formatterRound();
  return ListTile(
      title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Flexible(
          child: AutoSizeText(
              "Total premio: $total $money Monto: $pretotal $money",
              style: TextStyle(
                  fontSize: 17,
                  color: themeGlobal.primaryColor,
                  fontWeight: FontWeight.bold))),
    ],
  ));
}

warning(BuildContext context, String texto, NavigationEvents nav) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.WARNING,
    animType: AnimType.BOTTOMSLIDE,
    title: 'Advertencia',
    desc: 'Por favor ingresar un $texto.',
    btnOkText: "Ir",
    btnOkColor: themeGlobal.accentColor,
    btnOkOnPress: () {
      navItem(context, nav);
    },
  ).show();
}

class Clipper extends CustomClipper<Path> {
  final bool inSencond;
  Clipper({this.inSencond: true});
  @override
  Path getClip(Size size) {
    Path path = Path();
    if (inSencond) {
      path.lineTo(0.0, size.height);
      path.lineTo(size.width / 2, size.height - 50.0);
      path.lineTo(size.width, 0.0);
    } else {
      path.lineTo(size.width - 250.0, size.height - 50.0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0.0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget cardNum(
    {TicketsDet data,
    Function onPressed,
    String money: "C\$",
    Tarifario tarifario}) {
  final numero = data.numero;
  final monto = data.calculos("pretotal").formatterRound();
  final premio = data.calculos("premio").formatterRound();
  return Card(
    elevation: 3,
    color: Colors.grey[50],
    child: ListTile(
        leading: Chip(
          backgroundColor: themeGlobal.accentColor,
          padding: EdgeInsets.all(0),
          label: Text("$numero", style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          "Premio: $premio $money",
          style: TextStyle(fontSize: 17),
        ),
        subtitle: Text(
          "Monto: $monto $money",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        trailing: SizedBox(
            width: 45, //
            height: 60,
            child: FlatButton(
              onPressed: onPressed,
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ))),
  );
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(3.0, size.height - 10.0);

    var firstControlPoint = Offset(23.0, size.height - 40.0);
    var firstEndPoint = Offset(38.0, size.height - 5.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(58.0, size.height - 40.0);
    var secondEndPoint = Offset(75.0, size.height - 5.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint = Offset(93.0, size.height - 40.0);
    var thirdEndPoint = Offset(110.0, size.height - 5.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    var fourthControlPoint = Offset(128.0, size.height - 40.0);
    var fourthEndPoint = Offset(150.0, size.height - 5.0);
    path.quadraticBezierTo(fourthControlPoint.dx, fourthControlPoint.dy,
        fourthEndPoint.dx, fourthEndPoint.dy);

    var fifthControlPoint = Offset(168.0, size.height - 40.0);
    var fifthEndPoint = Offset(185.0, size.height - 5.0);
    path.quadraticBezierTo(fifthControlPoint.dx, fifthControlPoint.dy,
        fifthEndPoint.dx, fifthEndPoint.dy);

    var sixthControlPoint = Offset(205.0, size.height - 40.0);
    var sixthEndPoint = Offset(220.0, size.height - 5.0);
    path.quadraticBezierTo(sixthControlPoint.dx, sixthControlPoint.dy,
        sixthEndPoint.dx, sixthEndPoint.dy);

    var sevenControlPoint = Offset(240.0, size.height - 40.0);
    var sevenEndPoint = Offset(255.0, size.height - 5.0);
    path.quadraticBezierTo(sevenControlPoint.dx, sevenControlPoint.dy,
        sevenEndPoint.dx, sevenEndPoint.dy);

    var eightControlPoint = Offset(275.0, size.height - 40.0);
    var eightEndPoint = Offset(290.0, size.height - 5.0);
    path.quadraticBezierTo(eightControlPoint.dx, eightControlPoint.dy,
        eightEndPoint.dx, eightEndPoint.dy);

    var ninthControlPoint = Offset(310.0, size.height - 40.0);
    var ninthEndPoint = Offset(330.0, size.height - 5.0);
    path.quadraticBezierTo(ninthControlPoint.dx, ninthControlPoint.dy,
        ninthEndPoint.dx, ninthEndPoint.dy);

    path.lineTo(size.width, size.height - 10.0);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget itemsNums(TicketsDet data, {String money: "C\$"}) {
  final numero = data.numero;
  return Column(
    children: <Widget>[
      ListTile(
        leading: Chip(
          backgroundColor: themeGlobal.accentColor,
          label: Text("$numero", style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          'Premio: ${data.calculos("premio").formatterRound()} $money',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
        trailing: Text(
          '$money${data.calculos("pretotal").formatterRound()}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
      ),
    ],
  );
}

Widget imgTicket() => Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: AssetImage('assets/entertainment.png'))),
      ),
    );

Widget totalesTicket(Tickets data, {String money: "C\$"}) {
  return Padding(
    padding: const EdgeInsets.only(top: 9.0),
    child: Column(
      children: <Widget>[
        Text(
          'Total Premio $money${data.getTotal("premio").formatterRound()}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17.0),
        ),
        Text(
          'Monto Total $money${data.getTotal("pretotal").formatterRound()}',
          style: TextStyle(
              color: themeGlobal.primaryColorDark,
              fontWeight: FontWeight.bold,
              fontSize: 17.0),
        )
      ],
    ),
  );
}
