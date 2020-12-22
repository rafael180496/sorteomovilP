import 'package:flutter/material.dart';

Widget bottomAppbar(
    Function refreshOnpressed, String titulo, Function searchOnpressed) {
  return BottomAppBar(
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
          border: Border(
        top: BorderSide(color: Colors.grey, width: 0.3),
      )),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.indigoAccent,
              size: 28,
            ),
            onPressed: refreshOnpressed,
          ),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'RobotoMono',
                  fontStyle: FontStyle.normal,
                  fontSize: 19),
            ),
          ),
          Wrap(children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                size: 28,
                color: Colors.indigoAccent,
              ),
              onPressed: searchOnpressed,
            ),
            Padding(
              padding: EdgeInsets.only(right: 5),
            )
          ])
        ],
      ),
    ),
  );
}
