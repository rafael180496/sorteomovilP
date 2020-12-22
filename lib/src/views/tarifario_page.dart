import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/blocs/tarifas/tarifario_bloc.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:state_persistence/state_persistence.dart';
import 'package:excel/excel.dart';

class TarifarioPage extends StatefulWidget with NavigationStates {
  final TarifarioBloc tarifarioBloc = TarifarioBloc();
  final bool indimport;
  TarifarioPage(this.indimport);
  @override
  _TarifarioPageState createState() => _TarifarioPageState();
}

class _TarifarioPageState extends State<TarifarioPage> {
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context);
    pr.style(
        message: 'Por Favor espere...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return PersistedStateBuilder(
      builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) =>
          Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 35, bottom: 0, top: 35),
                      child: _titleTarifario(),
                    ),
                    StreamBuilder(
                        stream: widget.tarifarioBloc.tarifario,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Tarifario>> snapshot) {
                          return Padding(
                              padding: EdgeInsets.only(top: 65),
                              child: _tableTarifario(snapshot));
                        }),
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton:widget.indimport ?  fabAdd(() {
                dialogCustom(
                    content: _advertenciaTarifario(),
                    context: context,
                    titulo: "Advertencia",
                    closeFunction: () {
                      _clearDialog();
                    });
              }):null),
    );
  }

  Widget _titleTarifario() {
    return Text(
      "Tarifas",
      style: TextStyle(
          color: themeGlobal.primaryColor,
          fontSize: 25,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _tableTarifario(AsyncSnapshot<List<Tarifario>> snapshot) {
    if (snapshot.hasData) {
      final double _width = MediaQuery.of(context).size.width / 4;
      final w1 = 18;
      final w2 = 16;
      List<Widget> _rows = [];
      for (var i = 0; i < ((snapshot.data.length) / 2).round(); i++) {
        int x = (i + (snapshot.data.length) / 2).round();
        _rows.add(Container(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 3,
              ),
              Container(
                  width: _width - w1,
                  height: 20,
                  decoration: BoxDecoration(
                      color: themeGlobal.accentColor,
                      border: Border.all(color: Colors.grey[400])),
                  child: AutoSizeText(' ${snapshot.data[i].valor}',
                      minFontSize: 1,
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey[100]))),
              Container(
                  width: _width + w2,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400])),
                  child: AutoSizeText(
                    ' ${snapshot.data[i].premio}',
                    minFontSize: 1,
                    maxLines: 1,
                  )),
              x == snapshot.data.length
                  ? Container()
                  : Container(
                      width: _width - w1,
                      height: 20,
                      decoration: BoxDecoration(
                          color: themeGlobal.accentColor,
                          border: Border.all(color: Colors.grey[400])),
                      child: AutoSizeText(' ${snapshot.data[x].valor}',
                          minFontSize: 1,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey[100]))),
              x == snapshot.data.length
                  ? Container()
                  : Container(
                      width: _width + w2,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[400])),
                      child: AutoSizeText(
                        ' ${snapshot.data[x].premio}',
                        maxLines: 1,
                        minFontSize: 1,
                      )),
            ],
          ),
        ));
      }

      return snapshot.data.length != 0
          ? Column(
              children: _rows,
            )
          : Container(
              child: Center(
              child: noItemsMessageWidget("Sin Tarifas"),
            ));
    } else {
      return Center(
        child: loadingDataTarifarios(),
      );
    }
  }

  Widget loadingDataTarifarios() {
    widget.tarifarioBloc.getTarifarios();
    return noItemsMessageWidget("Sin Tarifas");
  }

  void _pickerExcel() async {
    pr.show();
    FilePickerResult result = await FilePicker.platform.pickFiles();
    final auxprefs = await SharedPreferences.getInstance();
    final auxtipo = auxprefs.getString('tipo');

    if (result != null) {
      widget.tarifarioBloc.deleteAllTarifas();
      var bytes = File(result.files.single.path).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table].rows) {
          if (isNumeric(row[0].toString()) || row[0] == null) {
            Tarifario tarifario = Tarifario();
            if (row[0] != null && row[1] != null) {
              tarifario.tarifa = auxtipo;
              tarifario.valor = row[0].round();
              tarifario.premio = row[1].round();

              widget.tarifarioBloc.addTarifarios(tarifario);
            }

            if (row[2] != null && row[3] != null) {
              tarifario = Tarifario();
              tarifario.tarifa = auxtipo;
              tarifario.valor = row[2].round();
              tarifario.premio = row[3].round();

              widget.tarifarioBloc.addTarifarios(tarifario);
            }
          }
        }
      }
      License.internal().actualizarImport();
      widget.tarifarioBloc.getTarifarios();
      pr.hide();
    } else {
      pr.hide();
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  Widget _advertenciaTarifario() => Column(
        children: <Widget>[
          textMultiline(
              contenido:
                  "Se eliminara el tarifario actual, ¿seguro de continuar?",
              fontSize: 13,
              lines: 2),
          Wrap(
            spacing: 8,
            children: <Widget>[
              AccionBtn(
                colorText: Colors.red,
                onPressed: () {
                  _clearDialog();
                },
                textBtn: "Cancelar",
                icon: Icons.close,
              ),
              AccionBtn(
                  colorText: Colors.green,
                  onPressed: () {
                    _clearDialog();
                    _pickerExcel();
                  },
                  textBtn: "Continuar",
                  icon: Icons.arrow_forward),
            ],
          ),
        ],
      );

  _clearDialog() => Navigator.of(context).popUntil((route) => route.isFirst);
}
