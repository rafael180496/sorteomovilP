import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorteomovil/src/utils/native_methods.dart';

class DiscoveryPage extends StatefulWidget {
  @override
  _DiscoveryPage createState() => _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  List<dynamic> _bluetoothDevices = new List<dynamic>();
  Icon _iconToolBar = Icon(Icons.bluetooth_disabled_outlined);

  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _getListBlue();
  }

  Future<void> initPlatformState() async {
    var _enabled = await NativeMethods.isEnabled();
    if (_enabled) {
      setState(() {
        _iconToolBar = Icon(Icons.bluetooth_connected_outlined);
      });
    } else {
      setState(() {
        _iconToolBar = Icon(Icons.bluetooth_disabled_outlined);
      });
    }
  }

  Future<void> _getListBlue() async {
    try {
      final lista = await NativeMethods.getPairedDevices();
      setState(() {
        _bluetoothDevices = lista;
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _setMac(String mac, String name) async {
    final _preferences = await SharedPreferences.getInstance();
    _preferences.setString('mac', mac);
    _preferences.setString('namedevice', name);
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos'),
        actions: [
          IconButton(
              icon: _iconToolBar,
              onPressed: () {
                if (_enabled) {
                  NativeMethods.turnOff();
                  _enabled = false;
                  setState(() {
                    _iconToolBar = Icon(Icons.bluetooth_disabled_outlined);
                  });
                } else {
                  NativeMethods.turnOn();
                  _enabled = true;
                  _getListBlue();
                  setState(() {
                    _iconToolBar = Icon(Icons.bluetooth_connected_outlined);
                  });
                }
              }),
          IconButton(icon: Icon(Icons.replay), onPressed: _getListBlue)
        ],
      ),
      backgroundColor: Colors.white.withOpacity(.85),
      body: Center(
        child: Column(children: [
          Expanded(
            child: ListView(
              children: _bluetoothDevices
                  .asMap()
                  .map((key, value) => MapEntry(key, _deviceView(value)))
                  .values
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _deviceView(Map<dynamic, dynamic> dispositivo) {
    String titulo, subTitulo;
    Icon _iconDevices = Icon(Icons.print);
    dispositivo.forEach((key, value) {
      subTitulo = key;
      titulo = value['name'];
      switch (value['type']) {
        case "DESKTOP":
          _iconDevices = Icon(Icons.desktop_windows);
          break;
        case "LAPTOP":
          _iconDevices = Icon(Icons.laptop);
          break;
        case "PHONE":
          _iconDevices = Icon(Icons.phone_android);
          break;
        case "PRINTER":
          _iconDevices = Icon(Icons.print);
          break;
        default:
      }
    });
    return ListTile(
      leading: _iconDevices,
      title: Text(titulo),
      subtitle: Text(subTitulo),
      onTap: () => _setMac(subTitulo, titulo),
    );
  }
}
