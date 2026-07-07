import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataFormatada = DateFormat(
  "EEEE, dd 'de' MMMM 'de' yyyy",
  "pt_BR",
).format(DateTime.now());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemePage(
      onLogout: () async {
        bool logout = await context.read<LoginController>().logout();
        if (logout) {
          appRouter.go('/login');
        }
      },
      children: [
        Card(child: Column(
          children: [
            Text("Bem vindo, ${Preferences.instance.name}!"),
            Text(dataFormatada[0].toUpperCase() + dataFormatada.substring(1)),
          ],
        )),
      ],
    );
  }
}
