import 'package:sorteomovil/src/models/models.dart';

double totalValor = 0.0;
double totalPremio = 0.0;
int modo = 0;

Future<String> formarFactura(String titulo, String sorteo, Tickets tickets,
    int modoPV, String vendedor, String tiraje, String frase) async {
  try {
    modo = modoPV;
    String line = "--------------------------------";
    String columna = "";
    if (modo == 0) {
      columna = " Items | Numero |     Valor     ";
    } else {
      columna = " Items | Numero |     Premio    ";
    }
    DateTime today = new DateTime.now();
    String year = today.year.toString();
    String month = today.month.toString().padLeft(2, '0');
    String day = today.day.toString().padLeft(2, '0');

    String ampm = 'AM';
    if (today.hour >= 12 && today.hour <= 23) {
      ampm = 'PM';
    } else if (today.hour >= 00 && today.hour <= 11) {
      ampm = 'AM';
    }

    String hour = today.hour.toString().padLeft(2, '0');
    switch (today.hour) {
      case 13:
        hour = "1".padLeft(2, '0');
        break;
      case 14:
        hour = "2".padLeft(2, '0');
        break;
      case 15:
        hour = "3".padLeft(2, '0');
        break;
      case 16:
        hour = "4".padLeft(2, '0');
        break;
      case 17:
        hour = "5".padLeft(2, '0');
        break;
      case 18:
        hour = "6".padLeft(2, '0');
        break;
      case 19:
        hour = "7".padLeft(2, '0');
        break;
      case 20:
        hour = "8".padLeft(2, '0');
        break;
      case 21:
        hour = "9".padLeft(2, '0');
        break;
      case 22:
        hour = "10".padLeft(2, '0');
        break;
      case 23:
        hour = "11".padLeft(2, '0');
        break;
      case 00:
        hour = "12".padLeft(2, '0');
        break;
    }
    //String hour = today.hour.toString().padLeft(2, '0');
    String minute = today.minute.toString().padLeft(2, '0');
    var dateFormat = "$day/$month/$year $hour:$minute $ampm";
    String fecha = "Fecha: ${dateFormat.padLeft(25, ' ')}";

    StringBuffer recibo = new StringBuffer();

    recibo.write("$line\n");

    int residuo = 32 - titulo.length;
    int espacios = (residuo / 2).round();

    for (int i = 0; i <= espacios; i++) {
      titulo = " $titulo";
    }

    if (titulo.length >= 32) {
      titulo = titulo.substring(0, 32);
    }

    recibo.write("$titulo\n");
    recibo.write("$line\n");
    recibo.write(
        "${validarCaracteres("Sorteo: ${sorteo.trim().padLeft(24, ' ')}")}\n");
    if (vendedor != '') {
      recibo.write(
          "${validarCaracteres("Vendedor: ${vendedor.padLeft(22, ' ')}")}\n");
    }
    recibo.write("$fecha\n");
    recibo.write("$line\n");
    recibo.write("$columna\n");
    recibo.write("$line\n");

    for (int i = 0; i < tickets.detalle.length; i++) {
      recibo.write("${_concepto((i + 1).toString(), tickets.detalle[i])}\n");
    }

    recibo.write("$line\n");

    String totales = '';
    if (modo == 0) {
      totales =
          " TOTAL:    ${doubleComma(totalValor.toStringAsFixed(2)).padLeft(21, ' ')}";
    } else {
      totales =
          " TOTAL:    ${doubleComma(totalPremio.toStringAsFixed(2)).padLeft(21, ' ')}";
    }

    recibo.write("$totales\n");
    recibo.write("$line\n");
    recibo.write("$tiraje\n");
    recibo.write("          Buena Suerte!\n");

    if (frase != '') {
      residuo = 32 - titulo.length;
      espacios = (residuo / 2).round();

      for (int i = 0; i <= espacios; i++) {
        frase = " $frase";
      }
      recibo.write("$frase\n");
    }

    totalPremio = 0.0;
    totalValor = 0.0;
    return recibo.toString();
  } catch (e) {
    print(e);
  }
}

String _concepto(String id, TicketsDet ticketsDet) {
  totalValor += ticketsDet.calculos("pretotal");
  totalPremio += ticketsDet.calculos("premio");
  String items = '';
  switch (id.length) {
    case 1:
      items = "   ${id.toString()}   ";
      break;
    case 2:
      items = "  ${id.toString()}   ";
      break;
    case 3:
      items = " ${id.toString()}   ";
  }

  String numeros = '';
  switch (ticketsDet.numero.toString().length) {
    case 1:
      numeros = "     ${ticketsDet.numero.toString()}  ";
      break;
    case 2:
      numeros = "    ${ticketsDet.numero.toString()}  ";
      break;
  }

  if (modo == 0) {
    return "$items|$numeros|${doubleComma(ticketsDet.calculos("pretotal").toString()).padLeft(15, ' ')}";
  } else {
    return "$items|$numeros|${doubleComma(ticketsDet.calculos("premio").toString()).padLeft(15, ' ')}";
  }
}

String validarCaracteres(String palabra) {
  palabra = palabra
      .replaceAll('Ñ', 'N')
      .replaceAll('ñ', 'n')
      .replaceAll('é', 'e')
      .replaceAll('É', 'E')
      .replaceAll('á', 'a')
      .replaceAll('Á', 'A')
      .replaceAll('í', 'i')
      .replaceAll('Í', 'I')
      .replaceAll('ó', 'o')
      .replaceAll('Ó', 'O')
      .replaceAll('ú', 'u')
      .replaceAll('Ú', 'U');
  if (palabra.length > 32) {
    palabra = palabra.substring(0, 32);
  }
  return palabra;
}

String doubleComma(String value) {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  return value.replaceAllMapped(reg, mathFunc);
}
