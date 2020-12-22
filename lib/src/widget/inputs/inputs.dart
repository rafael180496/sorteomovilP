import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:sorteomovil/src/utils/formatter.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataModel {
  final int id;
  final String valor;
  dynamic data;

  DataModel({this.id, this.valor, this.data});

  @override
  String toString() => valor;

  @override
  operator ==(o) => o is DataModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ valor.hashCode;
}

enum TipoInput { Digit, DatePicker, Text, Switch, Select }

class InputGeneric extends StatefulWidget {
  final Key key;
  final String hintText, labelText, helperText, initialValue;
  final bool space, border, readOnly, enabled;
  final int range, maxLength;
  final void Function(String) onSaved, validator, onChanged, onPicker;
  final TextEditingController controller;
  final Color iconColor;
  final double iconSize;
  final IconData icon, suffixIcon;
  final TipoInput tipo;
  final bool enableInteractiveSelection;
  //switch
  final double minWidth, cornerRadius, switchTitleSize;
  final int initialLabelIndex;
  final String switchTitle, labelOn, labelOff;
  final IconData iconOn, iconOff;
  final Color onColor, offColor, switchTitleColor;
  final void Function(int) onToggle;
  //select
  final void Function(DataModel) onData;
  final void Function() onTap;
  final DataModel item;
  final List<DataModel> items;
  final String labelSelect;
  final FocusNode focusNode;

  InputGeneric(
      {this.key,
      this.readOnly: false,
      this.enabled: true,
      this.focusNode,
      //select
      this.item,
      this.onTap,
      this.labelSelect,
      this.items,
      //switch
      this.switchTitleColor: Colors.black,
      this.switchTitleSize: 20,
      this.onToggle,
      this.minWidth: 120.0,
      this.cornerRadius: 18,
      this.initialLabelIndex,
      this.switchTitle,
      this.labelOn,
      this.labelOff,
      this.iconOn,
      this.iconOff,
      this.onColor,
      this.offColor,
      //----
      //select
      this.onData,
      //-------
      this.hintText: "",
      this.labelText: "",
      this.helperText: "",
      this.tipo: TipoInput.Text,
      this.space: true,
      this.border: true,
      this.range: 2,
      this.maxLength,
      this.onSaved,
      this.onPicker,
      this.enableInteractiveSelection: true,
      this.validator,
      this.onChanged,
      this.controller,
      this.initialValue,
      this.iconColor,
      this.iconSize: 15,
      this.icon,
      this.suffixIcon});

  @override
  _InputGenericState createState() => _InputGenericState();
}

class _InputGenericState extends State<InputGeneric> {
  TextInputType _keyboard;
  OutlineInputBorder _border;
  List<TextInputFormatter> _formatter = [];
  var _ontap;
  List<IconData> _icons = [];

  InputDecoration _genDecoration() {
    _border = widget.border ? borderInput : null;
    return InputDecoration(
        suffixIcon: _getIcon(widget.suffixIcon),
        border: _border,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
        icon: _getIcon(widget.icon));
  }

  Icon _getIcon(IconData icon) => icon == null
      ? null
      : Icon(icon,
          size: widget.iconSize,
          color: widget.iconColor == null
              ? themeGlobal.primaryColor
              : widget.iconColor);

  _buildInput() {
    if (widget.tipo == TipoInput.DatePicker) {
      _ontap = () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context, widget.onPicker);
      };
    }
    if (widget.tipo == TipoInput.Select) {
      _ontap = () {
        _selectData(context);
      };
    }
    if (widget.tipo == TipoInput.Digit) {
      _formatter
          .add(DecimalTextInputFormatter(range: widget.range, negative: false));
      _keyboard = TextInputType.numberWithOptions(decimal: true);
    }
    if (widget.tipo == TipoInput.Text || widget.tipo == TipoInput.Select) {
      if (widget.space) {
        _formatter.add(
          FilteringTextInputFormatter(RegExp('[ ]'), allow: false),
        );
      }
      _keyboard = null;
    }
    if (widget.onTap != null) {
      _ontap = widget.onTap;
    }
    if (widget.tipo != TipoInput.Switch) {
      return TextFormField(
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        readOnly: widget.tipo == TipoInput.Select ? true : widget.readOnly,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: _ontap,
        focusNode: widget.focusNode,
        onSaved: widget.onSaved,
        initialValue: widget.initialValue == "" ? null : widget.initialValue,
        controller: widget.controller,
        validator: widget.validator,
        inputFormatters: _formatter,
        keyboardType: _keyboard,
        decoration: _genDecoration(),
        onChanged: widget.onChanged,
      );
    } else {
      if (widget.iconOff != null && widget.iconOn != null) {
        _icons..add(widget.iconOn)..add(widget.iconOff);
      } else {
        _icons = null;
      }
      return Column(
        children: <Widget>[
          Text(
            widget.switchTitle,
            style: TextStyle(
                color: widget.switchTitleColor,
                fontSize: widget.switchTitleSize),
          ),
          Divider(),
          ToggleSwitch(
              minWidth: widget.minWidth,
              cornerRadius: widget.cornerRadius,
              initialLabelIndex: widget.initialLabelIndex,
              activeBgColor: Colors.green,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              labels: [widget.labelOn, widget.labelOff],
              icons: _icons,
              activeBgColors: [widget.onColor, widget.offColor],
              onToggle: widget.onToggle)
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) => _buildInput();

  _selectData(BuildContext context) async {
    SelectDialog.showModal<DataModel>(
      context,
      emptyBuilder: (context) => Center(
        child: Text(
          "Sin datos",
          style: TextStyle(fontSize: 22, color: themeGlobal.primaryColorDark),
        ),
      ),
      titleStyle: TextStyle(color: themeGlobal.primaryColorDark, fontSize: 22),
      label: widget.labelSelect,
      searchBoxDecoration: InputDecoration(
        hintText: "ingrese un texto",
        labelText: "Buscar",
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
      ),
      items: widget.items,
      selectedValue: widget.item,
      itemBuilder: (BuildContext context, DataModel item, bool isSelected) {
        return Container(
            child: Card(
          elevation: 8,
          color: isSelected ? themeGlobal.primaryColor : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
              selected: isSelected,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(item.valor,
                      style: TextStyle(
                          fontSize: 17,
                          color: isSelected
                              ? Colors.white
                              : themeGlobal.primaryColorDark))
                ],
              )),
        ));
      },
      onChange: widget.onData,
    );
  }

  _selectDate(BuildContext context, void Function(String) onpicker) async {
    DateTime picked = await showDatePicker(
        helpText: "Seleccionar fecha",
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1994),
        lastDate: DateTime(2999),
        locale: Locale('es', 'ES'),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: themeGlobal.primaryColor,
                accentColor: themeGlobal.primaryColor,
                colorScheme:
                    ColorScheme.light(primary: themeGlobal.primaryColor),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child);
        });
    if (picked != null) {
      onpicker(picked.toString());
    }
  }
}
