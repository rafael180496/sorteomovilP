import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sorteomovil/src/models/Clientes.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/config.dart';

import 'inputs.dart';

void showSheet(BuildContext context, GlobalKey<FormState> form,
    {String titulo,
    String buttonText,
    List<Widget> formulario,
    Function onPressed}) {
  showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0))),
            child: DraggableScrollableSheet(
                initialChildSize: 0.14,
                minChildSize: 0.14,
                maxChildSize: 1.0,
                expand: false,
                builder: (_, scrollController) {
                  return Form(
                      key: form,
                      child: ListView(
                        shrinkWrap: true,
                        controller: scrollController,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: RotationTransition(
                              turns: AlwaysStoppedAnimation(180 / 360),
                              child: Image.asset("assets/arrow_up.gif",
                                  height: 48),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(25.0),
                                topRight: const Radius.circular(25.0),
                              ),
                            ),
                          ),
                          Divider(
                            color: themeGlobal.primaryColor,
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            alignment: Alignment.center,
                            child: Text(
                              titulo,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...formulario,
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: OutlineButton(
                                child: Text(buttonText),
                                onPressed: onPressed,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                          )
                        ],
                      ));
                }));
      });
}

List<Widget> getFormClienteSearch(Cliente _searchCliente) => [
      Container(
        height: 80,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
        child: InputGeneric(
            border: true,
            onSaved: (value) => _searchCliente.nombre = value,
            initialValue: "",
            hintText: "Nombre del cliente",
            labelText: "Nombre"),
      )
    ];

List<Widget> getFormClienteAddUpd(Cliente _newUpCliente) => [
      Container(
        height: 80,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
        child: InputGeneric(
            border: true,
            onSaved: (value) => _newUpCliente.nombre = value,
            initialValue: _newUpCliente.nombre,
            validator: (String value) {
              return value.isEmpty ? 'Nombre Vacio' : null;
            },
            hintText: "Nombre del cliente",
            labelText: "Nombre"),
      )
    ];

List<Widget> getFormTipoSorteoSearch(TipoSorteo _searchTipoSorteo) => [
      Container(
        height: 80,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
        child: InputGeneric(
            onSaved: (value) => _searchTipoSorteo.nombre = value,
            initialValue: "",
            hintText: "Nombre del Tipo de Sorteo",
            labelText: "Tipo de Sorteo"),
      ),
    ];

List<Widget> getFormTipoSorteoAddUpd(TipoSorteo _newUpTipoSorteo) => [
      Container(
        height: 80,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
        child: InputGeneric(
            border: true,
            onSaved: (value) => _newUpTipoSorteo.nombre = value,
            initialValue: _newUpTipoSorteo.nombre,
            validator: (String value) {
              return value.isEmpty ? 'Nombre Vacio' : null;
            },
            hintText: "Nombre del Tipo de Sorteo",
            labelText: "Tipo de Sorteo"),
      )
    ];

formModal(BuildContext context, Key key,
    {String titleText: "",
    double titleSize: 22,
    Color titleColor: Colors.black,
    Function preLoad,
    List<Widget> children,
    List<AccionBtn> acciones}) async {
  try {
    await preLoad();
  } catch (e) {
    print("Error:${e.toString()}");
  }
  Alert(
      style: AlertStyle(
          isOverlayTapDismiss: false,
          buttonAreaPadding: EdgeInsets.all(10),
          animationType: AnimationType.fromBottom,
          isCloseButton: false,
          titleStyle: TextStyle(
              color: titleColor,
              fontSize: titleSize,
              fontWeight: FontWeight.bold)),
      context: context,
      title: titleText,
      content: Form(
          key: key,
          child: Column(
            children:
                addListWidget(<List<Widget>>[children, _genAcciones(acciones)]),
          )),
      buttons: []).show();
}

List<Widget> _genAcciones(List<AccionBtn> acciones) {
  return <Widget>[
    Divider(),
    Wrap(spacing: 8, children: acciones),
  ];
}

class AccionBtn extends StatelessWidget {
  final Color colorText;
  final String textBtn;
  final IconData icon;
  final Key key;
  final Function onPressed;
  final double fontSize;
  AccionBtn(
      {this.key,
      this.colorText: Colors.white,
      this.textBtn: "",
      this.onPressed,
      this.icon,
      this.fontSize = 14 //Defaul Size
      });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (icon != null) {
      items.add(
        Icon(icon),
      );
    }
    items.add(
      Text(
        textBtn,
        style: TextStyle(fontSize: fontSize),
      ),
    );
    return FlatButton(
      textColor: colorText,
      onPressed: onPressed,
      child: Row(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}

List<Widget> addListWidget(List<List<Widget>> data) {
  List<Widget> result = [];
  if (data.isNotEmpty) {
    data.forEach((e) {
      if (e.isNotEmpty) {
        e.forEach((e) {
          result.add(e);
        });
      }
    });
  }
  return result;
}
