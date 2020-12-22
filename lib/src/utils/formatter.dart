import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({int range, bool negative})
      : assert(
            range == null || range >= 0, 'Error en DecimalTextInputFormatter') {
    String dp = (range != null && range > 0) ? "([.][0-9]{0,$range}){0,1}" : "";
    String num = "[0-9]*$dp";

    if (negative) {
      _exp = RegExp("^((((-){0,1})|((-){0,1}[0-9]$num))){0,1}\$");
    } else {
      _exp = RegExp("^($num){0,1}\$");
    }
  }

  RegExp _exp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
