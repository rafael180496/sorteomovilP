import 'package:flutter/services.dart';

class NativeMethods {
  static const _platform = const MethodChannel("com.sorteo.crazysales/Blue");

  static void turnOn() {
    print("on");
    _platform.invokeMethod("turnOn");
  }

  static turnOnAsync(){
    turnOn();
  }

  static void turnOff() {
    print("off");
    _platform.invokeMethod("turnOff");
  }

  static Future<bool> isEnabled() async {
    return await _platform.invokeMethod("isEnabled");
  }

  static Future<List<dynamic>> getPairedDevices() async {
    return await _platform.invokeMethod('getListDevices');
  }

  static void connectImp(String mac) {
    print(_platform.invokeMethod("connectImp", <String, String>{'mac': mac}));
  }

  static void destroyImp() {
    _platform.invokeMethod("desconnectImp");
  }

  static  imprimir(String recibo) {
    _platform.invokeMethod("imprimir", <String, String>{'recibo': recibo});
  }
}
