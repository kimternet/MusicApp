import 'dart:io';

class ServerConstant {
  static String serverUrl =
      Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
}

