import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget fabAdd(Function addonPressed) {
  return Padding(
    padding: EdgeInsets.only(bottom: 25),
    child: FloatingActionButton(
      elevation: 5.0,
      onPressed: addonPressed,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.add,
        size: 32,
        color: Colors.indigoAccent,
      ),
    ),
  );
}
