import 'package:flutter/material.dart';
import 'package:sorteomovil/src/utils/config.dart';
import 'package:sorteomovil/src/utils/routers.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class Main extends StatefulWidget {
  Main({Key key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English, no country code
        const Locale('es', 'ES'),
      ],
      debugShowCheckedModeBanner: false,
      title: valuesMsj["appname"],
      theme: themeGlobal,
      initialRoute: "splash",
      routes: routers,
       onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: routers["notfound"]);
      },
    );
  }
}