import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late ClienteListaController controller;

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
    controller = ClienteListaController(mockRepository);
  });

  group('ClienteListaController - getClientes', () {
    final listResponse = [
      {'id': 1, 'uid': 'cli-1', 'nome': 'Tatiana Pacheco'},
      {'id': 2, 'uid': 'cli-2', 'nome': 'Maria Silva'},
    ];

    blocTest<ClienteListaController, dynamic>(
      'deve emitir lista de clientes ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: listResponse,
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.getClientes(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.length, 2);
        expect(c.state.data![0].nome, 'Tatiana Pacheco');
        expect(c.state.data![1].nome, 'Maria Silva');
      },
    );

    blocTest<ClienteListaController, dynamic>(
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
      act: (c) => c.getClientes(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter clientes',
            ),
      ],
    );

    blocTest<ClienteListaController, dynamic>(
      'deve emitir erro genérico para status fora do padrão',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
          ),
        );
        return controller;
      },
      act: (c) => c.getClientes(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter clientes'),
      ],
    );

    blocTest<ClienteListaController, dynamic>(
      'deve emitir erro ao lançar DioException',
      build: () {
        when(() => mockRepository.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Erro de conexão',
          ),
        );
        return controller;
      },
      act: (c) => c.getClientes(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(
          c.state.hasError.toString(),
          contains('Ocorreu um erro ao obter clientes'),
        );
      },
    );
  });

  group('ClienteListaController - delete', () {
    blocTest<ClienteListaController, dynamic>(
      'deve remover cliente da lista ao excluir com sucesso (200)',
      build: () {
        controller.emit(
          controller.state.copyWith(
            data: [
              ClienteModel(id: 1, uid: 'cli-1', nome: 'Tatiana Pacheco'),
              ClienteModel(id: 2, uid: 'cli-2', nome: 'Maria Silva'),
            ],
          ),
        );
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('cli-1'),
      verify: (c) {
        expect(c.state.data!.length, 1);
        expect(c.state.data![0].uid, 'cli-2');
        expect(c.state.data![0].nome, 'Maria Silva');
      },
    );

    blocTest<ClienteListaController, dynamic>(
      'deve emitir erro interno ao tentar excluir e receber 500',
      build: () {
        controller.emit(
          controller.state.copyWith(
            data: [ClienteModel(id: 1, uid: 'cli-1', nome: 'Tatiana')],
          ),
        );
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('cli-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao excluir cliente',
            ),
      ],
    );

    blocTest<ClienteListaController, dynamic>(
      'deve emitir erro genérico ao tentar excluir com status inválido',
      build: () {
        controller.emit(
          controller.state.copyWith(
            data: [ClienteModel(id: 1, uid: 'cli-1', nome: 'Tatiana')],
          ),
        );
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('cli-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao excluir cliente'),
      ],
    );
  });

  group('ClienteListaController - busca ValueNotifier', () {
    test(
      'deve acionar estados de loading ao alterar o valor de busca',
      () async {
        final estados = <dynamic>[];
        final subscription = controller.stream.listen(estados.add);

        controller.busca.value = 'Tatiana';
        await Future.delayed(const Duration(milliseconds: 200));

        expect(estados.length, greaterThanOrEqualTo(2));
        expect(estados[0].isLoading, true);
        expect(estados[1].isLoading, false);

        await subscription.cancel();
      },
    );
  });
}
