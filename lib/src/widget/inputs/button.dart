import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sorteomovil/src/utils/utils.dart';

SpeedDialChild newChild(Function onEvent, String label, IconData icon,
        {bool inWarning: false}) =>
    SpeedDialChild(
      elevation: 7,
      child:
          Icon(icon, color: inWarning ? Colors.red : themeGlobal.accentColor),
      backgroundColor: Colors.white,
      onTap: onEvent,
      label: label,
      labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      labelBackgroundColor: inWarning ? Colors.red : themeGlobal.accentColor,
    );

SpeedDial buildSpeedDial(bool dialVisible,
    {Function onRefresh,
    Function onNew,
    Function onFilter,
    Function onCancel,
    Function onSave}) {
  List<SpeedDialChild> accs = [];
  if (onNew != null) {
    accs.add(newChild(onNew, "Nuevo", Icons.add));
  }
  if (onFilter != null) {
    accs.add(newChild(onFilter, "Filtrar", Icons.search));
  }
  if (onRefresh != null) {
    accs.add(newChild(onRefresh, "Refrescar", Icons.refresh));
  }
  if (onCancel != null) {
    accs.add(newChild(onCancel, "Cancelar", Icons.cancel, inWarning: true));
  }
  if (onSave != null) {
    accs.add(newChild(onSave, "Guardar", Icons.save));
  }
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    backgroundColor: themeGlobal.accentColor,
    animatedIconTheme: IconThemeData(size: 25.0),
    visible: dialVisible,
    curve: Curves.bounceIn,
    children: accs,
  );
}

Widget circleButton(
        {IconData icon, Function onPressed, Color color: Colors.blue}) =>
    Expanded(
        flex: 2,
        child: MaterialButton(
          elevation: 6,
          onPressed: onPressed,
          color: color,
          textColor: Colors.white,
          child: Icon(
            icon,
            size: 22,
          ),
          padding: EdgeInsets.all(8),
          shape: CircleBorder(),
        ));
Widget btnAccs(String btntext, Color btnColor, Function onPressed,
    {IconData icon, iconColor: Colors.blueGrey, bool enabled: true}) {
  final child = icon != null
      ? Icon(icon, size: 35, color: iconColor)
      : Text(
          btntext,
          style: TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        );
  return Container(
    padding: EdgeInsets.only(bottom: 9.0),
    child: FlatButton(
      child: child,
      onPressed: enabled ? onPressed : null,
      color: btnColor,
      padding: EdgeInsets.all(18.0),
      splashColor: Colors.grey,
      shape: CircleBorder(),
    ),
  );
}
