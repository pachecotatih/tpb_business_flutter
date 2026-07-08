import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tpb_business_flutter/core/app/app_widget.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.instance.init();
  await initializeDateFormatting('pt_BR', null);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const AppWidget());
}