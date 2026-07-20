import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/item/fluxo_caixa_item_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late FluxoCaixaItemController controller;

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
    controller = FluxoCaixaItemController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('FluxoCaixaItemController - get', () {
    blocTest<FluxoCaixaItemController, dynamic>(
      'deve carregar detalhes do item ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'uid': 'fc-1',
              'descricao': 'Pagamento de Serviço',
              'valor': 150.0,
              'tipo_movimentacao': 'entrada',
              'forma_pagamento': 'dinheiro',
              'pago': true,
              'created_at': '2026-07-20T10:00:00.000Z',
            },
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.get('fc-1'),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.uid, 'fc-1');
        expect(c.state.data!.descricao, 'Pagamento de Serviço');
        expect(c.state.data!.valor, 150.0);
        expect(c.state.data!.tipoMovimentacao, 'entrada');
        expect(c.state.data!.pago, true);
      },
    );

    blocTest<FluxoCaixaItemController, dynamic>(
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
      act: (c) => c.get('fc-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro interno ao obter fluxo de caixa'),
      ],
    );

    blocTest<FluxoCaixaItemController, dynamic>(
      'deve emitir erro genérico para status fora do padrão',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        );
        return controller;
      },
      act: (c) => c.get('fc-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter fluxo de caixa'),
      ],
    );

    test('não deve fazer requisição quando uid está vazio', () async {
      await controller.get('');
      verifyNever(() => mockRepository.get(any()));
    });
  });

  group('FluxoCaixaItemController - save', () {
    final savedItemResponse = {
      'uid': 'fc-new',
      'descricao': 'Nova entrada',
      'valor': 200.0,
      'tipo_movimentacao': 'entrada',
      'forma_pagamento': 'dinheiro',
      'pago': false,
      'created_at': '2026-07-20T11:00:00.000Z',
    };

    test('deve enviar POST e retornar true ao criar novo lançamento (uid nulo)', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: null, descricao: 'Nova entrada', valor: 200.0),
        ),
      );

      when(() => mockRepository.post(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: savedItemResponse,
          statusCode: 201,
        ),
      );

      final result = await controller.save();
      expect(result, true);
      expect(controller.state.data!.uid, 'fc-new');
      verify(() => mockRepository.post(any(), any())).called(1);
    });

    test('deve enviar PUT e retornar true ao editar lançamento existente', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1', descricao: 'Editado', valor: 250.0),
        ),
      );

      final updatedResponse = {
        'uid': 'fc-1',
        'descricao': 'Editado',
        'valor': 250.0,
        'tipo_movimentacao': 'entrada',
        'forma_pagamento': 'dinheiro',
        'pago': false,
        'created_at': '2026-07-20T11:00:00.000Z',
      };

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: updatedResponse,
          statusCode: 200,
        ),
      );

      final result = await controller.save();
      expect(result, true);
      expect(controller.state.data!.descricao, 'Editado');
      expect(controller.state.data!.valor, 250.0);
      verify(() => mockRepository.put(any(), any())).called(1);
    });

    test('deve retornar false e emitir erro de validação ao receber 422', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'errors': 'Valor é obrigatório'},
          statusCode: 422,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Valor é obrigatório');
    });

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao salvar fluxo de caixa');
    });

    test('deve retornar false e emitir erro genérico para status padrão', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro ao salvar fluxo de caixa');
    });
  });

  group('FluxoCaixaItemController - delete', () {
    test('deve retornar true e limpar dados ao excluir com sucesso (200)', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1', descricao: 'Lançamento'),
        ),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await controller.delete();
      expect(result, true);
    });

    test('deve retornar false e emitir erro interno ao falhar com 500', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao excluir fluxo de caixa');
    });

    test('deve retornar false e emitir erro genérico para status padrão', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(controller.state.hasError, 'Erro ao excluir fluxo de caixa');
    });

    test('deve retornar false ao lançar DioException no delete', () async {
      controller.emit(
        controller.state.copyWith(
          data: FluxoCaixaItemModel(uid: 'fc-1'),
        ),
      );

      when(() => mockRepository.delete(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Falha de rede',
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(
        controller.state.hasError.toString(),
        contains('Ocorreu um erro ao excluir fluxo de caixa'),
      );
    });
  });
}
