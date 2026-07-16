import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/services/dio_repository.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/features/agendamentos/calendario/agendamento_calendario_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/calendario/agendamento_calendario_page.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/agendamento_item_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/agendamento_item_page.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_controller.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_page.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_controller.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_page.dart';
import 'package:tpb_business_flutter/features/config/configuracoes_page.dart';
import 'package:tpb_business_flutter/features/config/user/user_controller.dart';
import 'package:tpb_business_flutter/features/config/user/user_page.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/item/fluxo_caixa_item_controller.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/item/fluxo_caixa_item_page.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/lista/fluxo_caixa_lista_controller.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/lista/fluxo_caixa_lista_page.dart';
import 'package:tpb_business_flutter/features/home/home_controller.dart';
import 'package:tpb_business_flutter/features/home/home_page.dart';
import 'package:tpb_business_flutter/features/login/cadastrar_page.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_page.dart';
import 'package:tpb_business_flutter/features/servicos/item/servico_item_controller.dart';
import 'package:tpb_business_flutter/features/servicos/item/servico_item_page.dart';
import 'package:tpb_business_flutter/features/servicos/lista/servico_lista_controller.dart';
import 'package:tpb_business_flutter/features/servicos/lista/servico_lista_page.dart';

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
      builder: (context, state) => BlocProvider(
        create: (_) => HomeController(DioRepository()),
        child: HomePage(),
      ),
    ),
    GoRoute(
      path: '/configuracoes',
      name: 'configuracoes',
      builder: (context, state) => const ConfiguracoesPage(),
    ),
    GoRoute(
      path: '/user',
      name: 'user',
      builder: (context, state) => BlocProvider(
        create: (_) => UserController(DioRepository()),
        child: const UserPage(),
      ),
    ),
    GoRoute(
      path: '/cliente',
      name: 'cliente',
      builder: (context, state) => BlocProvider(
        create: (_) => ClienteListaController(DioRepository()),
        child: const ClienteListaPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'cliente.novo',
          builder: (context, state) {
            bool? isAgendamento = state.extra as bool?;
            return BlocProvider(
              create: (_) => ClienteItemController(DioRepository()),
              child: ClienteItemPage(
                uid: '',
                isAgendamento: isAgendamento ?? false,
              ),
            );
          },
        ),
        GoRoute(
          path: ':uid',
          name: 'cliente.editar',
          builder: (context, state) {
            final uid = state.pathParameters['uid'] ?? '';
            return BlocProvider(
              create: (_) => ClienteItemController(DioRepository()),
              child: ClienteItemPage(uid: uid),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/servico',
      name: 'servico',
      builder: (context, state) => BlocProvider(
        create: (_) => ServicoListaController(DioRepository()),
        child: const ServicoListaPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'servico.novo',
          builder: (context, state) {
            bool? isAgendamento = state.extra as bool?;
            return BlocProvider(
              create: (_) => ServicoItemController(DioRepository()),
              child: ServicoItemPage(
                uid: '',
                isAgendamento: isAgendamento ?? false,
              ),
            );
          },
        ),
        GoRoute(
          path: ':uid',
          name: 'servico.editar',
          builder: (context, state) {
            final uid = state.pathParameters['uid'] ?? '';
            return BlocProvider(
              create: (_) => ServicoItemController(DioRepository()),
              child: ServicoItemPage(uid: uid),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/fluxocaixa',
      name: 'fluxocaixa',
      builder: (context, state) => BlocProvider(
        create: (_) => FluxoCaixaListaController(DioRepository()),
        child: const FluxoCaixaListaPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'fluxocaixa.novo',
          builder: (context, state) => BlocProvider(
            create: (_) => FluxoCaixaItemController(DioRepository()),
            child: FluxoCaixaItemPage(uid: ''),
          ),
        ),
        GoRoute(
          path: ':uid',
          name: 'fluxocaixa.editar',
          builder: (context, state) {
            final uid = state.pathParameters['uid'] ?? '';
            return BlocProvider(
              create: (_) => FluxoCaixaItemController(DioRepository()),
              child: FluxoCaixaItemPage(uid: uid),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/agendamento',
      name: 'agendamento',
      builder: (context, state) => BlocProvider(
        create: (_) => AgendamentoCalendarioController(DioRepository()),
        child: const AgendamentoCalendarioPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'agendamento.novo',
          builder: (context, state) {
            DateTime data = state.extra is Map
                ? (state.extra as Map)["data"]
                : DateTime.now();

            return BlocProvider(
              create: (_) => AgendamentoItemController(DioRepository()),
              child: AgendamentoItemPage(uid: '', date: data),
            );
          },
        ),
        GoRoute(
          path: ':uid',
          name: 'agendamento.editar',
          builder: (context, state) {
            final uid = state.pathParameters['uid'] ?? '';
            DateTime data = state.extra is Map
                ? (state.extra as Map)["data"]
                : DateTime.now();
            return BlocProvider(
              create: (_) => AgendamentoItemController(DioRepository()),
              child: AgendamentoItemPage(uid: uid, date: data),
            );
          },
        ),
      ],
    ),
  ],
);
