import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';

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

  static Future<void> logoutUser(BuildContext context) async {
    bool logout = await context.read<LoginController>().logout();
    if (logout) {
      appRouter.go('/login');
    }
  }
}
