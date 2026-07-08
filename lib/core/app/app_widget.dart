import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TPB Business',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Cores.primaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routerConfig: appRouter,
    );
  }
}
