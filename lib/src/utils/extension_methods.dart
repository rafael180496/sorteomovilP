extension StringCapitalizes on String {
  String capitalizeString() {
    String nombreCapitalize = "";

    List<String> palabras = this.split(" ");

    palabras.forEach((element) {
      nombreCapitalize =
          "$nombreCapitalize${element[0].toUpperCase()}${element.substring(1).toLowerCase()} ";
    });

    return nombreCapitalize;
  }
}

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

extension DoubleRedondeo on double {
  double formatterRound({int decimal: 2}) {
    return double.parse(this.toStringAsFixed(decimal));
  }
}

extension DatimeCompare on DateTime {
  String toStr({String separate: "/", bool inHr: false}) {
    String hr = "";
    if (inHr) {
      hr = "${this.hour}:${this.minute}:${this.second}";
    }
    return "${this.year}$separate${this.month}$separate${this.day} $hr";
  }

  int compareDate(DateTime vl, {bool inHr: false}) {
    final vlorig = this;
    if (vlorig.year > vl.year) {
      return 1;
    }
    if (vlorig.year < vl.year) {
      return -1;
    }
    if (vlorig.month > vl.month) {
      return 1;
    }
    if (vlorig.month < vl.month) {
      return -1;
    }
    if (vlorig.day > vl.day) {
      return 1;
    }
    if (vlorig.day < vl.day) {
      return -1;
    }
    if (inHr) {
      if (vlorig.hour > vl.hour) {
        return 1;
      }
      if (vlorig.hour < vl.hour) {
        return -1;
      }
      if (vlorig.minute > vl.minute) {
        return 1;
      }
      if (vlorig.minute < vl.minute) {
        return -1;
      }
    }
    return 0;
  }
}

extension intConvert on int {
  bool intTobool() => this == 1 ? true : false;
}

extension boolConvert on bool {
  int boolToint() => this ? 1 : 0;
}
