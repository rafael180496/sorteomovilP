import 'package:flutter/material.dart';
import 'package:sorteomovil/src/views/myapp.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:state_persistence/state_persistence.dart';
 
void main() => runApp(Myapp());


class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return PersistedAppState(
      storage: JsonFileStorage(
        filename: paramValues["datakey"],
        initialData: paramsInit
      ),
      child: Main()
      );
  }
}