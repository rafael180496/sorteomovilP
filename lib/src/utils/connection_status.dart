import 'dart:async';
import 'dart:io';

class ConnectionStatus {
  static final ConnectionStatus _instance = ConnectionStatus.internal();

  ConnectionStatus.internal();

  factory ConnectionStatus() {
    return _instance;
  }

  Future<bool> checkConnection() async {
    bool hasConnection = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    return hasConnection;
  }
}
