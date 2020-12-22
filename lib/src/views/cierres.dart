import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:sorteomovil/src/blocs/navigation_bloc.dart';
import 'package:sorteomovil/src/models/models.dart';
import 'package:sorteomovil/src/utils/enums.dart';
import 'package:sorteomovil/src/utils/utils.dart';
import 'package:sorteomovil/src/widget/widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:state_persistence/state_persistence.dart';

class CierresView extends StatefulWidget with NavigationStates {
  final tarifa;

  CierresView(this.tarifa);
  @override
  _CierresViewState createState() => _CierresViewState();
}

class _CierresViewState extends State<CierresView> {
  TextEditingController _inputFieldSelectSorteo =
      TextEditingController(text: "");
  var sorteo = DataModel(id: -1, valor: valuesMsj["defaultSorteo"]);
  var inPremio = true;
  int _cantTicket = 0;
  List<DataModel> clientes, sorteos, tarifario;
  List<TicketsDet> _detTicket = List<TicketsDet>();
  GlobalKey previewContainer = new GlobalKey();
  int originalSize = 800;
  String _nombrefoto = "";
  @override
  void initState() {
    super.initState();
    SorteoModel.getData().then((items) {
      setState(() {
        sorteos = items;
      });
    });

    TarifarioModel.getData().then((value) {
      tarifario = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistedStateBuilder(
        builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) =>
            Scaffold(
                body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 35, bottom: 0, top: 35),
                    child: _titleCierre(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 10),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            flex: 7,
                            child: InputGeneric(
                              enableInteractiveSelection: true,
                              controller: _inputFieldSelectSorteo,
                              validator: (vl) {
                                if (vl == valuesMsj["defaultSorteo"] ||
                                    vl.trim() == "") {
                                  return "Ingrese un Sorteo";
                                }
                                return null;
                              },
                              labelText: "Sorteo",
                              hintText: "ingrese un Sorteo",
                              items: sorteos,
                              item: sorteo,
                              tipo: TipoInput.Select,
                              labelSelect: "Seleccione un Sorteo",
                              border: false,
                              onData: (data) {
                                setState(() {
                                  _inputFieldSelectSorteo.text = data.valor;
                                  sorteo = data;
                                  _cargarDet();
                                });
                              },
                            )),
                        Flexible(
                            flex: 1,
                            child: RawMaterialButton(
                              onPressed: () {
                                if (_detTicket.length > 0) {
                                  _setNameExcel(
                                      snap.data["usuario"].toString());
                                  _shared(context, snap);
                                }
                              },
                              elevation: 2.0,
                              fillColor: themeGlobal.accentColor,
                              child: Icon(
                                Icons.share,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              shape: CircleBorder(),
                            ))
                      ],
                    ),
                  ),
                  _totalesSorteo(),
                  _tableSorteo(snap.data["usuario"].toString())
                ],
              ),
            )));
  }

  _shared(BuildContext context, AsyncSnapshot<PersistedData> snap) {
    WillPopScope errorDialog = WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Compartir',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              SizedBox(
                width: 200,
                child: RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () {
                      _generarExcel(snap.data["usuario"].toString());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.arrow_downward),
                        Text("Excel")
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
              ),
              SizedBox(
                width: 200,
                child: RaisedButton(
                    color: themeGlobal.accentColor,
                    textColor: Colors.white,
                    onPressed: () {
                      ShareFilesAndScreenshotWidgets().shareScreenshot(
                          previewContainer,
                          originalSize,
                          "Title",
                          "Name.png",
                          "image/png",
                          text: _nombrefoto);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.image),
                        Text("Captura de imagen")
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
              ),
              SizedBox(
                width: 200,
                child: RaisedButton(
                    color: Colors.redAccent,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Icon(Icons.close), Text("Cancelar")],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0))),
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => errorDialog);
  }

  Widget _totalesSorteo() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 6,
          child: CheckboxListTile(
            activeColor: themeGlobal.primaryColor,
            controlAffinity: ListTileControlAffinity.leading,
            title: AutoSizeText(
              "Premio",
              minFontSize: 1,
              maxLines: 1,
            ),
            value: inPremio,
            onChanged: (vl) {
              setState(() {
                inPremio = vl;
              });
            },
          ),
        ),
        Flexible(
          flex: 3,
          child: AutoSizeText(
            "${_getTotalTicket()}\n${_getTotalMonto()} ",
            minFontSize: 1,
            maxLines: 2,
          ),
        ),
        Flexible(
          flex: 3,
          child: AutoSizeText(
            "${_getTotalNumero()}\n${_getTotalPremio()} ",
            minFontSize: 1,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _titleCierre() {
    return Text(
      "Cierre de sorteo",
      style: TextStyle(
          color: themeGlobal.primaryColor,
          fontSize: 25,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _tableSorteo(String user) {
    _getNameFoto(user);
    final double _width = MediaQuery.of(context).size.width / 8;
    final w1 = 18;
    final w2 = 16;
    List<Widget> _rows = [];
    var nums = [0, 25, 50, 75];
    for (var i = 0; i < 25; i++) {
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
                child: AutoSizeText(' ${nums[0]}',
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
                  _getValor(nums[0]),
                  minFontSize: 1,
                  maxLines: 1,
                )),
            Container(
                width: _width - w1,
                height: 20,
                decoration: BoxDecoration(
                    color: themeGlobal.accentColor,
                    border: Border.all(color: Colors.grey[400])),
                child: AutoSizeText(' ${nums[1]}',
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
                  _getValor(nums[1]),
                  maxLines: 1,
                  minFontSize: 1,
                )),
            Container(
                width: _width - w1,
                height: 20,
                decoration: BoxDecoration(
                    color: themeGlobal.accentColor,
                    border: Border.all(color: Colors.grey[400])),
                child: AutoSizeText(' ${nums[2]}',
                    maxLines: 1,
                    minFontSize: 1,
                    style: TextStyle(color: Colors.grey[100]))),
            Container(
                width: _width + w2,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[400])),
                child: AutoSizeText(
                  _getValor(nums[2]),
                  maxLines: 1,
                  minFontSize: 1,
                )),
            Container(
                width: _width - w1,
                height: 20,
                decoration: BoxDecoration(
                    color: themeGlobal.accentColor,
                    border: Border.all(color: Colors.grey[400])),
                child: AutoSizeText(' ${nums[3]}',
                    maxLines: 1,
                    minFontSize: 1,
                    style: TextStyle(color: Colors.grey[100]))),
            Container(
                width: _width + w2,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[400])),
                child: AutoSizeText(
                  _getValor(nums[3]),
                  maxLines: 1,
                  minFontSize: 1,
                )),
          ],
        ),
      ));

      for (var j = 0; j < nums.length; j++) {
        nums[j]++;
      }
    }
    return RepaintBoundary(
      key: previewContainer,
      child: Column(
        children: _rows,
      ),
    );
  }

  setCell(Sheet sheet, String _nameExcel) async {
    if (_detTicket.length > 0) {
      sheet.merge(CellIndex.indexByString("B2"), CellIndex.indexByString("E2"),
          customValue: _nameExcel);
      Map<int, String> detTicket = Map<int, String>();
      double premio = 0.0;
      double itotalTicket = 0;
      _detTicket.forEach((element) {
        if (inPremio) {
          premio += element.calculos("premio");
          premio = premio.formatterRound();
          detTicket.addAll({element.numero: "${element.calculos("premio")}"});
        } else {
          itotalTicket = itotalTicket + element.cant;
          detTicket.addAll({element.numero: element.cant.toString()});
        }
      });

      int row = 4;

      for (int i = 0; i < 34; i++) {
        if (i >= 0 && i <= 34) {
          var cell1 = sheet.cell(CellIndex.indexByString("A$row"));
          var cell2 = sheet.cell(CellIndex.indexByString("B$row"));
          String numero, valor;
          bool ready = false;
          detTicket.forEach((key, value) {
            if (!ready) {
              if (key == i) {
                numero = key.toString();
                valor = value;
                ready = true;
              } else {
                numero = i.toString();
                valor = "0.0";
              }
            }
          });
          cell1.value = numero;
          cell2.value = valor;
          row++;
        }
      }

      row = 4;
      for (int i = 34; i < 67; i++) {
        if (i >= 34 && i <= 67) {
          var cell1 = sheet.cell(CellIndex.indexByString("C$row"));
          var cell2 = sheet.cell(CellIndex.indexByString("D$row"));
          String numero, valor;
          bool ready = false;
          detTicket.forEach((key, value) {
            if (!ready) {
              if (key == i) {
                numero = key.toString();
                valor = value;
                ready = true;
              } else {
                numero = i.toString();
                valor = "0.0";
              }
            }
          });
          cell1.value = numero;
          cell2.value = valor;
          row++;
        }
      }

      row = 4;
      for (int i = 67; i < 100; i++) {
        if (i >= 67 && i <= 99) {
          var cell1 = sheet.cell(CellIndex.indexByString("E$row"));
          var cell2 = sheet.cell(CellIndex.indexByString("F$row"));
          String numero, valor;
          bool ready = false;
          detTicket.forEach((key, value) {
            if (!ready) {
              if (key == i) {
                numero = key.toString();
                valor = value;
                ready = true;
              } else {
                numero = i.toString();
                valor = "0.0";
              }
            }
          });
          cell1.value = numero;
          cell2.value = valor;
          row++;
        }
      }

      sheet.merge(
          CellIndex.indexByString("B39"), CellIndex.indexByString("E39"),
          customValue: inPremio ? "$premio" : "$itotalTicket");
    }
  }

  List<TicketsDet> _acumulador(List<TicketsDet> data) {
    List<TicketsDet> newlist = [];
    data.forEach((vl) {
      newlist = TicketDetModel.addIndex(vl, newlist, vl.tarifas);
    });
    return newlist;
  }

  void _cargarDet() async {
    final listticketdet = await TicketDetModel.getAll(sorteo: sorteo.id);
    final listticket = await TicketModel.getAll(sorteo: sorteo.id);

    List<TicketsDet> listNewTarifa = List();
    if (widget.tarifa == Tarifas.ESPECIAL) {
      for (var det in listticketdet) {
        if (det.valorTarifa == -1 &&
            det.premioTarifa == -1 &&
            widget.tarifa == Tarifas.ESPECIAL) {
          var values = _getValueTarifarios(det.cant.toInt(), 0);
          det.valorTarifa = values[0];
          det.premioTarifa = values[1];
          det.tarifas = widget.tarifa;
        }
        listNewTarifa.add(det);
      }
    }

    final count = listticket.length;
    List<TicketsDet> dep;
    if (widget.tarifa == Tarifas.ESPECIAL) {
      dep = _acumulador(listNewTarifa);
    } else {
      dep = _acumulador(listticketdet);
    }
    setState(() {
      _detTicket = dep;
      _cantTicket = count;
    });
  }

  String _getValor(int numero) {
    String valor = "0.0";
    _detTicket.forEach((element) {
      if (inPremio) {
        if (numero == element.numero) {
          valor = "${element.calculos("premio")}";
        }
      } else {
        if (numero == element.numero) {
          valor = element.cant.toString();
        }
      }
    });
    return valor;
  }

  List _getValueTarifarios(int parse, int option) {
    int premio = 0;
    int valor = 0;

    for (var tarifa in tarifario) {
      if (option == 0) {
        if (parse == tarifa.data.valor) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      } else {
        if (parse == tarifa.data.premio) {
          premio = tarifa.data.premio;
          valor = tarifa.data.valor;
          break;
        }
      }
    }
    return [valor, premio];
  }

  String _getTotalTicket() => "T.N.: ${_detTicket.length} ";

  String _getTotalMonto() {
    double itotalTicket = 0;
    _detTicket.forEach((element) {
      itotalTicket = itotalTicket + element.cant;
    });
    return "T.M.: ${itotalTicket.formatterRound()} ";
  }

  String _getTotalNumero() => "T.T.: $_cantTicket ";

  String _getTotalPremio() {
    double premio = 0.0;
    _detTicket.forEach((element) {
      premio += element.calculos("premio");
    });
    premio = premio.formatterRound();
    return "T.P.: $premio";
  }

  _generarExcel(String user) async {
    if (_detTicket.length > 0) {
      String name = await _setNameExcel(user);
      Excel excel = Excel.createExcel();
      excel.rename('Sheet1', 'Lista');
      String path = await _getPath();
      Sheet sheet = excel['Lista'];
      await setCell(sheet, name);
      await _createExcel(excel, path, name);
      await _excel(path, name);
    }
  }

  _getNameFoto(String user) async {
    try {
      await _setNameExcel(user).then((value) {
        setState(() {
          _nombrefoto = value;
        });
      });
    } catch (e) {}
  }

  Future<String> _getPath() async {
    Directory appDocDirectory = await getTemporaryDirectory();
    String pathExcel = "";

    try {
      await Directory(appDocDirectory.path)
          .create(recursive: true)
          .then((Directory directory) {
        pathExcel = directory.path;
      });
    } catch (value) {
      print("errorpath:$value");
    }

    return pathExcel;
  }

  _createExcel(Excel excel, String pathExcel, String _nameExcel) async {
    try {
      await excel.encode().then((onValue) {
        File("$pathExcel/$_nameExcel.xlsx")
          ..createSync(recursive: true)
          ..writeAsBytesSync(onValue);
      });
    } catch (value) {
      print("createError:$value");
    }
  }

  _excel(String pathExcel, String _nameExcel) async {
    try {
      Uri myUri = Uri.parse("$pathExcel/$_nameExcel.xlsx");
      File excelFile = new File.fromUri(myUri);
      Uint8List list;
      await excelFile.readAsBytes().then((value) {
        list = Uint8List.fromList(value);
        ShareFilesAndScreenshotWidgets().shareFile(
            "Title", "$_nameExcel.xlsx", list, "excel/xlsx",
            text: "Archivo del dia");
      });
    } catch (value) {
      print("Error envio:$value");
    }
  }

  Future<String> _setNameExcel(String user) async {
    final data = await SorteoModel.getId(sorteo.id, inTipo: true);
    return data == null
        ? ""
        : "$user-${data.tipoObj.nombre}_${data.fecha.day}-${data.fecha.month}-${data.fecha.year}";
  }
}
