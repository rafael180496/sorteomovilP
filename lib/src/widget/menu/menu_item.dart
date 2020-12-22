import 'package:flutter/material.dart';
import 'package:sorteomovil/src/utils/utils.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;
  final bool wasTaped;
  final bool isVisible;

  const MenuItem(
      {Key key,
      this.icon,
      this.title,
      this.onTap,
      this.wasTaped,
      this.isVisible = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                color: wasTaped
                    ? themeGlobal.primaryColorDark
                    : themeGlobal.primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(25.0),
                    bottomRight: const Radius.circular(25.0))),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 5, top: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 31,
                  ),
                  SizedBox(
                    width: 21,
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
