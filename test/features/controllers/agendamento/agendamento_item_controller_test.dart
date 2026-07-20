import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/agendamento_item_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late AgendamentoItemController controller;

  final clienteListResponse = [
    {'id': 1, 'uid': 'cli-1', 'nome': 'Cliente Teste'},
  ];
  final servicoListResponse = [
    {'uid': 's1', 'nome': 'Serviço A', 'valor_padrao': 50.0, 'ativo': true},
  ];

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
    controller = AgendamentoItemController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('AgendamentoItemController - get (uid vazio = novo)', () {
    blocTest<AgendamentoItemController, dynamic>(
      'deve carregar clientes e serviços ao criar novo agendamento (uid vazio)',
      build: () {
        when(() => mockRepository.get('/cliente')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: clienteListResponse,
            statusCode: 200,
          ),
        );
        when(() => mockRepository.get('/servico')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: servicoListResponse,
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.get(''),
      verify: (c) {
        expect(c.state.data!.uid, null);
        expect(c.state.data!.clientes, isNotNull);
        expect(c.state.data!.clientes!.first.nome, 'Cliente Teste');
        expect(c.state.data!.servicosInit, isNotNull);
        expect(c.state.data!.servicosInit!.first.nome, 'Serviço A');
      },
    );

    blocTest<AgendamentoItemController, dynamic>(
      'deve emitir erro quando clientes retornam 500 no modo novo',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer((invocation) async {
  final url = invocation.positionalArguments.first as String;

  if (url.endsWith('/cliente')) {
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: 500,
    );
  }

  if (url.endsWith('/servico')) {
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: 200,
      data: [],
    );
  }

  throw UnimplementedError(url);
});
        return controller;
      },
      act: (c) => c.get(''),
      verify: (c) {
        expect(c.state.hasError, 'Erro interno ao obter clientes');
      },
    );
  });

  group('AgendamentoItemController - get (uid com valor = editar)', () {
    blocTest<AgendamentoItemController, dynamic>(
      'deve carregar agendamento, clientes e serviços ao editar (200)',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'uid': 'agend-123', 'status': 'agendado'},
            statusCode: 200,
          ),
        );
        when(() => mockRepository.get('/cliente')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: clienteListResponse,
            statusCode: 200,
          ),
        );
        when(() => mockRepository.get('/servico')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: servicoListResponse,
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.get('agend-123'),
      verify: (c) {
        expect(c.state.data!.uid, 'agend-123');
        expect(c.state.data!.clientes!.first.nome, 'Cliente Teste');
        expect(c.state.data!.servicosInit!.first.nome, 'Serviço A');
      },
    );

    blocTest<AgendamentoItemController, dynamic>(
      'deve emitir erro interno ao buscar agendamento e retornar 500',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        return controller;
      },
      act: (c) => c.get('agend-123'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter agendamento',
            ),
      ],
    );

    blocTest<AgendamentoItemController, dynamic>(
      'deve emitir erro genérico ao buscar agendamento com status inválido',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        );
        return controller;
      },
      act: (c) => c.get('agend-123'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter agendamento'),
      ],
    );
  });

  group('AgendamentoItemController - save', () {
    test(
      'deve enviar POST e retornar true ao criar novo agendamento (uid nulo)',
      () async {
        controller.emit(
          controller.state.copyWith(data: AgendamentoModel(uid: null)),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'uid': 'new-agend', 'status': 'agendado'},
            statusCode: 201,
          ),
        );

        final result = await controller.save();
        expect(result, true);
        expect(controller.state.data!.uid, 'new-agend');
        verify(() => mockRepository.post(any(), any())).called(1);
      },
    );

    test(
      'deve enviar PUT ao editar agendamento existente (uid preenchido)',
      () async {
        controller.emit(
          controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
        );

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'uid': 'agend-123', 'status': 'concluido'},
            statusCode: 200,
          ),
        );

        final result = await controller.save();
        expect(result, true);
        expect(controller.state.data!.status, 'concluido');
        verify(() => mockRepository.put(any(), any())).called(1);
      },
    );

    test(
      'deve retornar false e definir erro de validação ao receber 422',
      () async {
        controller.emit(
          controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
        );

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'errors': 'Data é obrigatória'},
            statusCode: 422,
          ),
        );

        final result = await controller.save();
        expect(result, false);
        expect(controller.state.hasError, 'Data é obrigatória');
      },
    );

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao salvar agendamento');
    });
  });

  group('AgendamentoItemController - delete', () {
    test(
      'deve retornar true e limpar data ao excluir com sucesso (200)',
      () async {
        controller.emit(
          controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
        );

        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final result = await controller.delete();
        expect(result, true);
      },
    );

    test('deve retornar false e emitir erro interno ao falhar (500)', () async {
      controller.emit(
        controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao excluir agendamento');
    });

    test('deve retornar false ao lançar DioException', () async {
      controller.emit(
        controller.state.copyWith(data: AgendamentoModel(uid: 'agend-123')),
      );

      when(() => mockRepository.delete(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Timeout ao excluir',
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(
        controller.state.hasError.toString(),
        contains('Ocorreu um erro ao excluir agendamento'),
      );
    });
  });
}
