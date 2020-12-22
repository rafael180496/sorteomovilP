/*Contiene las configuraciones de la aplicacions */
import 'package:flutter/material.dart';

final themeGlobal = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: HexColor.fromHex("#673AB7"),
  primaryColorDark: HexColor.fromHex("#512DA8"),
  primaryColorLight: HexColor.fromHex("#D1C4E9"),
  accentColor: HexColor.fromHex("#448AFF"),
  dividerColor: HexColor.fromHex("#BDBDBD"),
);

/*Captura colores hexadecimal */
extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
