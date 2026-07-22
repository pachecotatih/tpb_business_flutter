import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/home/home_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late HomeController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'email': 'tatianapacheco09@gmail.com',
      'token': 'mock_token',
      'user': 'Tatiana',
      'name': 'Tatiana',
      'moeda': 'R\$',
      'refreshToken': 'mock_refresh',
      'deviceId': 'mock_device_id',
    });
    await Preferences.instance.init();
    mockRepository = MockRepository();
    controller = HomeController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('HomeController - getHome', () {
    final homeResponse = {
      'saldo_hoje': 500.0,
      'entradas_hoje': 700.0,
      'saidas_hoje': 200.0,
      'agendamentos_hoje': [
        {
          'uid': 'agend-1',
          'cliente': {'id': 1, 'nome': 'Cliente do Dia', 'uid': 'cli-1'},
          'status': 'agendado',
          'data_inicio': '2026-07-20T09:00:00.000Z',
          'data_fim': '2026-07-20T10:00:00.000Z',
          'valor_total': 150.0,
        },
      ],
    };

    blocTest<HomeController, dynamic>(
      'deve emitir HomeModel populado ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: homeResponse,
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.getHome(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.saldoHoje, 500.0);
        expect(c.state.data!.entradasHoje, 700.0);
        expect(c.state.data!.saidasHoje, 200.0);
        expect(c.state.data!.agendamentosHoje!.length, 1);
        expect(c.state.data!.agendamentosHoje![0].uid, 'agend-1');
      },
    );

    blocTest<HomeController, dynamic>(
      'deve emitir erro interno ao retornar 500',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        return controller;
      },
      act: (c) => c.getHome(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter dados da home',
            ),
      ],
    );

    blocTest<HomeController, dynamic>(
      'deve emitir erro genérico para status fora do padrão',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );
        return controller;
      },
      act: (c) => c.getHome(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro ao obter dados da home',
            ),
      ],
    );

    blocTest<HomeController, dynamic>(
      'deve emitir erro ao lançar DioException',
      build: () {
        when(() => mockRepository.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Timeout na home',
          ),
        );
        return controller;
      },
      act: (c) => c.getHome(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, isNotNull);
        expect(
          c.state.hasError.toString(),
          contains('Erro ao obter dados da home'),
        );
      },
    );
  });
}
