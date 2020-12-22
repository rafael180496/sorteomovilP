import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/blocs/blocs.dart';
import 'package:sorteomovil/src/blocs/splash_bloc.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:sorteomovil/src/views/license_sm_page.dart';
import 'package:sorteomovil/src/widget/widget.dart';

Widget _getAvatar(BuildContext context) => CircleAvatar(
      backgroundColor: Colors.white,
      maxRadius: 40,
      child: Image.asset(
        paramValues["logofile2"],
        height: 70,
        width: 70,
      ),
    );
Widget _textProject() => Text(
      valuesMsj["appname"],
      style: TextStyle(
          color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
    );

Widget _loading() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        Text(
          valuesMsj["store"],
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        )
      ],
    );

Widget _logoLoad(BuildContext context) => Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _getAvatar(context),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          _textProject()
        ],
      ),
    );

Widget _splashlayout(BuildContext context) => Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 2, child: _logoLoad(context)),
              Expanded(flex: 1, child: _loading())
            ],
          )
        ],
      ),
    );

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SplashBloc _splashBloc = SplashBloc(SplashInitial());
  @override
  void initState() {
    _splashBloc.add(SetSplash());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _splashBloc,
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            _license(context);
          }
        },
        child: _splashlayout(context),
      ),
    );
  }

  void _license(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('key') ?? " ";
    bool unautorized = prefs.getBool('unauthorized') ?? false;

    final tipo = await setSwitchTipo();
    final tarifa = await getTarifas();

    if (key == " ") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LicenseSMPage(unautorized),
        ),
      );
    } else {
      final activado = prefs.getBool('activado') ?? false;
      if (activado && key != " ") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SideBarLayout(
              tipo: tipo,
              tarifa: tarifa,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LicenseSMPage(unautorized),
          ),
        );
      }
    }
  }
}
