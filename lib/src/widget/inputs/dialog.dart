import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sorteomovil/src/utils/utils.dart';

dialogCustom(
    {@required BuildContext context,
    Function closeFunction,
    String titulo,
    @required Widget content}) async {
  Alert(
      context: context,
      closeFunction: closeFunction,
      style: AlertStyle(
          animationType: AnimationType.fromBottom,
          isCloseButton: true,
          titleStyle: TextStyle(
              color: themeGlobal.primaryColorDark,
              fontSize: 22,
              fontWeight: FontWeight.bold)),
      title: "Advertencia",
      content: content,
      buttons: []).show();
}
