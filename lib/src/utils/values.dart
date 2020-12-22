import 'package:flutter/material.dart';

/*Archivos que contiene los strings del proyecto */
final nd = "ND";

/*valuesMsj : mensajes constantes */
final Map<String, String> valuesMsj = {
  "appname": "Crazy Sales",
  "store": """crazy sales for everyone""",
  "nbdefault": "Sin nombre",
  "version":"1.1.2",
  "ajuste": "Ajustes y parametros",
  "save": "Guardando datos...",
  "savebtn": "Guardar datos",
  "w": "Where.",
  "off": "Finalizado",
  "on": "Abierto",
  "defaultTipo": "seleccione el tipo",
  "defaultCliente": "seleccione un cliente",
  "defaultSorteo": "seleccione un sorteo"
};

/*paramValues: Contiene las constantes del proyecto*/
final Map<String, dynamic> paramValues = {
  "dbversion": 2,
  "dbname": "sorteo.db",
  "datakey": "sorteovalues.json",
  "logofile": "assets/shopping.png",
  "logofile2": "assets/shopping.png",
  "dateformat": "yyyy-MM-dd",
  "datemax": "2999-12-31 00:00:00",
  "datemin": "1900-01-01 00:00:00",
  "nummin": 0,
  "nummax": 99,
  "vlcalc": 1000.00,
  "diasvenc":5
};

/*styles: Contiene las estilos constasten de los wigdet*/
final Map<String, TextStyle> styles = {
  "titulos":
      TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
  "subtitulos": TextStyle(color: Colors.white, fontSize: 18),
};

final Map<String, dynamic> values = {
  "spacetopside": 32.0,
  "sizecirimage": 40.0,
  "radiusimage": 30.0
};

/*Constantes iniciales que estaran en el storage state*/
final Map<String, dynamic> paramsInit = {
  "descuento": 0,
  "premio": 15.00,
  "usuario": "Prueba",
  "moneda": 'C\$',
  "titulo_recibo": "Crazy Sales"
};

final borderInput =
    OutlineInputBorder(borderRadius: BorderRadius.circular(25.0));
