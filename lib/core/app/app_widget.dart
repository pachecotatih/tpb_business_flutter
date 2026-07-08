import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/dio_repository.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginController(DioRepository())),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
