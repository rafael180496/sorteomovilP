import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void launchWhatsApp(
    {@required BuildContext context,
    @required String phone,
    @required String message,
    @required GlobalKey<ScaffoldState> scaffoldKey}) async {
  String url() {
    if (Platform.isIOS) {
      return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
    } else {
      return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
    }
  }

  if (await canLaunch(url())) {
    await launch(url());
  } else {
    final snackBar = SnackBar(
      content: Text('Error al ejecutar WhatsApp!'),
    );
    Navigator.pop(context);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

void launchEmail(
    {@required BuildContext context,
    @required String para,
    @required String asunto,
    @required String body,
    @required GlobalKey<ScaffoldState> scaffoldKey}) async {
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '$para',
      queryParameters: {'subject': '$asunto', 'body': '$body'});

  String url = _emailLaunchUri.toString().replaceAll("+", " ");
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    final snackBar = SnackBar(
      content: Text('Error al enviar correo!'),
    );
    Navigator.pop(context);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

void makePhoneCall(
    {@required BuildContext context,
    @required String numero,
    @required GlobalKey<ScaffoldState> scaffoldKey}) async {
  String url = "tel:$numero";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    final snackBar = SnackBar(
      content: Text('Error al realizar la llamada!'),
    );
    Navigator.pop(context);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
