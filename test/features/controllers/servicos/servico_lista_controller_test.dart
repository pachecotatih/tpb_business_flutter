import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/servicos/lista/servico_lista_controller.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late ServicoListaController controller;

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
    controller = ServicoListaController(mockRepository);
  });

  group('ServicoListaController - getServicos', () {
    final listResponse = [
      {'uid': 's1', 'nome': 'Corte de Cabelo', 'valor_padrao': 50.0, 'ativo': true},
      {'uid': 's2', 'nome': 'Manicure', 'valor_padrao': 35.0, 'ativo': false},
    ];

    blocTest<ServicoListaController, dynamic>(
      'deve emitir lista de serviços ao retornar 200',
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
      act: (c) => c.getServicos(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.length, 2);
        expect(c.state.data![0].nome, 'Corte de Cabelo');
        expect(c.state.data![0].valorPadrao, 50.0);
        expect(c.state.data![1].nome, 'Manicure');
      },
    );

    blocTest<ServicoListaController, dynamic>(
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
      act: (c) => c.getServicos(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro interno ao obter serviços'),
      ],
    );

    blocTest<ServicoListaController, dynamic>(
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
      act: (c) => c.getServicos(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter serviços'),
      ],
    );
  });

  group('ServicoListaController - delete', () {
    blocTest<ServicoListaController, dynamic>(
      'deve remover serviço da lista ao excluir com sucesso (200)',
      build: () {
        controller.emit(controller.state.copyWith(data: [
          ServicoModel(uid: 's1', nome: 'Corte de Cabelo'),
          ServicoModel(uid: 's2', nome: 'Manicure'),
        ]));
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('s1'),
      verify: (c) {
        expect(c.state.data!.length, 1);
        expect(c.state.data![0].uid, 's2');
      },
    );

    blocTest<ServicoListaController, dynamic>(
      'deve emitir erro interno ao excluir e receber 500',
      build: () {
        controller.emit(controller.state.copyWith(data: [
          ServicoModel(uid: 's1', nome: 'Corte de Cabelo'),
        ]));
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('s1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro interno ao excluir serviço'),
      ],
    );

    blocTest<ServicoListaController, dynamic>(
      'deve emitir erro genérico para status inválido ao excluir',
      build: () {
        controller.emit(controller.state.copyWith(data: [
          ServicoModel(uid: 's1', nome: 'Corte de Cabelo'),
        ]));
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );
        return controller;
      },
      act: (c) => c.delete('s1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao excluir serviço'),
      ],
    );
  });

  group('ServicoListaController - updateAtivo', () {
    test('deve retornar true e ativar o serviço localmente ao ter sucesso (200)', () async {
      controller.emit(controller.state.copyWith(data: [
        ServicoModel(uid: 's1', nome: 'Corte de Cabelo', ativo: false),
      ]));

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await controller.updateAtivo('s1', true);
      expect(result, true);
      expect(controller.state.data![0].ativo, true);
    });

    test('deve reverter o ativo localmente e retornar false ao receber 500', () async {
      controller.emit(controller.state.copyWith(data: [
        ServicoModel(uid: 's1', nome: 'Corte de Cabelo', ativo: false),
      ]));

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.updateAtivo('s1', true);
      expect(result, false);
      expect(controller.state.data![0].ativo, false);
      expect(controller.state.hasError.toString(), 'Erro interno ao alterar o ativo do serviço');
    });

    test('deve reverter o ativo e emitir erro genérico para status padrão', () async {
      controller.emit(controller.state.copyWith(data: [
        ServicoModel(uid: 's1', nome: 'Corte de Cabelo', ativo: true),
      ]));

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );

      final result = await controller.updateAtivo('s1', false);
      expect(result, false);
      expect(controller.state.data![0].ativo, true);
      expect(controller.state.hasError, 'Erro ao alterar o ativo do serviço');
    });
  });

  group('ServicoListaController - busca ValueNotifier', () {
    test('deve acionar estados de loading ao alterar o valor de busca', () async {
      final estados = <dynamic>[];
      final subscription = controller.stream.listen(estados.add);

      controller.busca.value = 'Corte';
      await Future.delayed(const Duration(milliseconds: 200));

      expect(estados.length, greaterThanOrEqualTo(2));
      expect(estados[0].isLoading, true);
      expect(estados[1].isLoading, false);

      await subscription.cancel();
    });
  });
}
