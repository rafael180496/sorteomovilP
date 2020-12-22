enum Tarifas { NORMAL, ESPECIAL }
enum Seleccion { PREMIO, VALOR }

String stringValueTar(Tarifas tarifa) {
  String resultado;
  switch (tarifa) {
    case Tarifas.NORMAL:
      resultado = "Normal";
      break;
    case Tarifas.ESPECIAL:
      resultado = "Especial";
      break;
  }
  return resultado;
}

String stringValueSel(Seleccion seleccion) {
  String resultado;
  switch (seleccion) {
    case Seleccion.PREMIO:
      resultado = "Premio";
      break;
    case Seleccion.VALOR:
      resultado = "Valor";
      break;
  }
  return resultado;
}

Tarifas getTarifasFromString(String tarifasAsString) {
  for (Tarifas element in Tarifas.values) {
    if (element.toString() == tarifasAsString) {
      return element;
    }
  }

  return Tarifas.NORMAL;
}

Seleccion getSeleccionFromString(String seleccionAsString) {
  for (Seleccion element in Seleccion.values) {
    if (element.toString() == seleccionAsString) {
      return element;
    }
  }

  return Seleccion.VALOR;
}
