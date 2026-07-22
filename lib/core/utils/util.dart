import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';

class Util {
  static String getDeviceName() {
    if (kIsWeb) {
      return "web";
    }
    try {
      if (Platform.isAndroid) return "android";
    } catch (_) {}
    return "test_device";
  }

  static String getDeviceId() {
    if (kIsWeb) {
      return "web_${DateTime.now().millisecondsSinceEpoch}";
    }
    try {
      if (Platform.isAndroid) {
        return "android_${DateTime.now().millisecondsSinceEpoch}";
      }
    } catch (_) {}
    return "test_${DateTime.now().millisecondsSinceEpoch}";
  }

  static Future<void> logoutUser(BuildContext context) async {
    bool logout = await context.read<LoginController>().logout();
    if (logout && context.mounted) {
      context.pushReplacement('/login');
    }
  }

  static String stringFormatValor(double valor) {
    final format = NumberFormat.simpleCurrency(
      locale: Preferences.instance.moeda == 'R\$'
          ? 'pt_BR'
          : (Preferences.instance.moeda == '\$' ? 'en_US' : 'de_DE'),
      name: '',
    );
    return format.format(valor);
  }

  static String dateFormatString(String data) {
    String dataNova = DateFormat('dd/MM/yyyy').format(DateTime.parse(data));
    return dataNova;
  }

  static String timeFormatString(String data) {
    String dataNova = DateFormat('HH:mm').format(DateTime.parse(data));
    return dataNova;
  }

  static DateTime dateFormatDateTime(String value) {
    return (value != '')
        ? DateTime.parse(
            DateFormat(
              'yyyy-MM-dd',
            ).format((DateFormat("dd/MM/yyyy").parse(value))),
          )
        : DateTime.parse('2000-01-01');
  }
}
