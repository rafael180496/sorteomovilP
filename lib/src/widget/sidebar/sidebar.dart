import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sorteomovil/src/utils/config.dart';
import 'package:sorteomovil/src/utils/values.dart';
import 'package:state_persistence/state_persistence.dart';

import '../widget.dart';

class SideBar extends StatefulWidget {
  _SideBarView createState() => _SideBarView();
}

class _SideBarView extends State<SideBar>
    with SingleTickerProviderStateMixin<SideBar> {
  AnimationController _animationController;
  StreamController<bool> isSideBarOpendStreamController;
  Stream<bool> isSideBarOpenedStream;
  StreamSink<bool> isSideBarOpenedSink;
  final _animationDuration = Duration(milliseconds: 350);
  List<MenuItem> _listMenu = List<MenuItem>();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSideBarOpendStreamController = PublishSubject<bool>();
    isSideBarOpenedStream = isSideBarOpendStreamController.stream;
    isSideBarOpenedSink = isSideBarOpendStreamController.sink;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await menu(context, onIconPressed).then((value) {
        _listMenu = value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSideBarOpendStreamController.close();
    isSideBarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSideBarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSideBarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    menu(context, onIconPressed).then((value) {
      setState(() {
        _listMenu = value;
      });
    });

    final screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<bool>(
      initialData: false,
      stream: isSideBarOpenedStream,
      builder: (context, snapshot) {
        return AnimatedPositioned(
            duration: _animationDuration,
            top: 0,
            bottom: 0,
            left: snapshot.data ? 0 : -screenWidth,
            right: snapshot.data ? 0 : screenWidth - 40,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: themeGlobal.primaryColor,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: values["spacetopside"],
                        ),
                        _loadDetUser(),
                        Divider(
                          height: 30,
                          thickness: 0.5,
                          color: Colors.white.withOpacity(0.3),
                          indent: 32,
                          endIndent: 32,
                        ),
                        ..._listMenu,
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "© ${DateTime.now().year} ${valuesMsj['appname']}",
                              style: styles["subtitulos"],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment(0, -0.89),
                    child: GestureDetector(
                        onTap: () {
                          onIconPressed();
                        },
                        child: ClipPath(
                          clipper: CustomMenuClipper(),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: 38,
                            height: 100,
                            color: themeGlobal.primaryColor,
                            child: AnimatedIcon(
                              progress: _animationController.view,
                              icon: AnimatedIcons.menu_close,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        )))
              ],
            ));
      },
    );
  }
}

Widget _loadDetUser() => PersistedStateBuilder(
        builder: (BuildContext context, AsyncSnapshot<PersistedData> snap) {
      if (snap.hasData) {
        return ListTile(
          title: Text(
            snap.data["usuario"],
            style: styles["titulos"],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            maxRadius: values["radiusimage"],
            child: Image.asset(
              paramValues["logofile"],
              height: values["sizecirimage"],
              width: values["sizecirimage"],
            ),
          ),
        );
      } else {
        return CircularProgressIndicator();
      }
    });

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final heigth = size.height;

    Path path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 15);
    path.quadraticBezierTo(width - 1, heigth / 2 - 20, width, heigth / 2);
    path.quadraticBezierTo(width + 1, heigth / 2 + 20, 10, heigth - 16);
    path.quadraticBezierTo(0, heigth - 8, 0, heigth);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
