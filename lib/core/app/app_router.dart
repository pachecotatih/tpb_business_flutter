import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/services/dio_repository.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_controller.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_page.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_controller.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_page.dart';
import 'package:tpb_business_flutter/features/config/configuracoes_page.dart';
import 'package:tpb_business_flutter/features/config/user/user_controller.dart';
import 'package:tpb_business_flutter/features/config/user/user_page.dart';
import 'package:tpb_business_flutter/features/home/home_page.dart';
import 'package:tpb_business_flutter/features/login/cadastrar_page.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_page.dart';

GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        bool? cadastrarExtra = state.extra as bool?;
        return BlocProvider(
          create: (_) => LoginController(DioRepository()),
          child: LoginPage(userCadastrado: (cadastrarExtra ?? false)),
        );
      },
    ),
    GoRoute(
      path: '/cadastrar',
      name: 'cadastrar',
      builder: (context, state) => BlocProvider(
        create: (_) => LoginController(DioRepository()),
        child: const CadastrarPage(),
      ),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      redirect: (context, state) {
        if (Preferences.instance.token.isEmpty) {
          return '/login';
        }
        return '/';
      },
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/configuracoes',
      name: 'configuracoes',
      builder: (context, state) => const ConfiguracoesPage(),
    ),
    GoRoute(
      path: '/user',
      name: 'user',
      builder: (context, state) => MultiBlocProvider(
        key: UniqueKey(),
        providers: [
          BlocProvider(create: (_) => UserController(DioRepository())),
        ],
        child: const UserPage(),
      ),
    ),
    GoRoute(
      path: '/cliente',
      name: 'cliente',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ClienteListaController(DioRepository())),
        ],
        child: const ClienteListaPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'cliente.novo',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ClienteItemController(DioRepository())),
            ],
            child: ClienteItemPage(uid: ''),
          ),
        ),
        GoRoute(
          path: ':uid',
          name: 'cliente.editar',
          builder: (context, state) {
            final uid = state.pathParameters['uid'] ?? '';
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ClienteItemController(DioRepository())),
              ],
              child: ClienteItemPage(uid: uid),
            );
          },
        ),
      ]
    ),
  ],
);
