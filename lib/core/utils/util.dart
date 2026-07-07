import 'dart:io';

import 'package:flutter/foundation.dart';

class Util {
  static String getDeviceName() {
    if (kIsWeb) {
      return "web";
    } else if (Platform.isAndroid) {
      return "android";
    }
    throw UnsupportedError("Plataforma não suportada.");
  }

  static String getDeviceId() {
    if (kIsWeb) {
      return "web_${DateTime.now().millisecondsSinceEpoch}";
    } else if (Platform.isAndroid) {
      return "android_${DateTime.now().millisecondsSinceEpoch}";
    }
    throw UnsupportedError("Plataforma não suportada.");
  }
}
