import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/agendamentos/calendario/agendamento_calendario_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/meetings_model.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late AgendamentoCalendarioController controller;

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
    controller = AgendamentoCalendarioController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('AgendamentoCalendarioController - getAgendamentos', () {
    final listResponse = [
      {
        'uid': 'agend-123',
        'cliente': {'id': 1, 'nome': 'Cliente Teste', 'uid': 'cli-1'},
        'status': 'pendente',
        'data_inicio': '2026-07-20T12:00:00.000Z',
        'data_fim': '2026-07-20T13:00:00.000Z',
        'cliente_id': 1,
        'observacao': 'Observação',
        'valor_total': 100.0,
        'servicos': [
          {
            'uid': 's1',
            'nome': 'Serviço Teste',
            'valor_padrao': 100.0,
            'ativo': true,
          }
        ],
      }
    ];

    blocTest<AgendamentoCalendarioController, dynamic>(
      'deve emitir estados corretos ao retornar 200',
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
      act: (c) => c.getAgendamentos(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data, isNotNull);
        expect(c.state.data!.appointments!.length, 1);
        final meeting = c.state.data!.appointments!.first as Meeting;
        expect(meeting.uid, 'agend-123');
        expect(meeting.eventName, 'Cliente Teste');
        expect(meeting.status, 'pendente');
      },
    );

    blocTest<AgendamentoCalendarioController, dynamic>(
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
      act: (c) => c.getAgendamentos(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro interno ao obter agendamentos'),
      ],
    );

    blocTest<AgendamentoCalendarioController, dynamic>(
      'deve emitir erro genérico ao retornar status diferente de 200/500',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );
        return controller;
      },
      act: (c) => c.getAgendamentos(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter agendamentos'),
      ],
    );

    blocTest<AgendamentoCalendarioController, dynamic>(
      'deve emitir erro ao lançar DioException',
      build: () {
        when(() => mockRepository.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Timeout',
          ),
        );
        return controller;
      },
      act: (c) => c.getAgendamentos(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, isNotNull);
        expect(
          c.state.hasError.toString(),
          contains('Ocorreu um erro ao obter agendamentos'),
        );
      },
    );
  });

  group('AgendamentoCalendarioController - updateAgendamentos', () {
    late Meeting meeting;

    setUp(() {
      meeting = Meeting(
        uid: 'agend-123',
        clienteId: 1,
        from: DateTime.parse('2026-07-20T12:00:00.000Z'),
        to: DateTime.parse('2026-07-20T13:00:00.000Z'),
        status: 'concluido',
        valorTotal: 150.0,
        servicos: [],
      );
    });

    test('deve retornar true ao atualizar com sucesso (200)', () async {
      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await controller.updateAgendamentos(meeting);
      expect(result, true);
      expect(controller.state.isLoading, false);
    });

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.updateAgendamentos(meeting);
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao atualizar agendamento');
    });

    test('deve retornar false e emitir erro de validação ao receber 422', () async {
      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'errors': 'Data de início inválida'},
          statusCode: 422,
        ),
      );

      final result = await controller.updateAgendamentos(meeting);
      expect(result, false);
      expect(controller.state.hasError, 'Data de início inválida');
    });

    test('deve retornar false ao lançar DioException', () async {
      when(() => mockRepository.put(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Erro de rede',
        ),
      );

      final result = await controller.updateAgendamentos(meeting);
      expect(result, false);
      expect(controller.state.hasError.toString(), isNotEmpty);
    });
  });

  group('AgendamentoCalendarioController - deleteAgendamento', () {
    test('deve retornar true e remover o meeting do estado ao excluir com sucesso', () async {
      final meetingParaExcluir = Meeting(uid: 'agend-123');
      controller.emit(
        controller.state.copyWith(data: MeetingDataSource([meetingParaExcluir])),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await controller.deleteAgendamento('agend-123');
      expect(result, true);
      expect(controller.state.data!.appointments!.length, 0);
    });

    test('deve retornar false e emitir erro ao falhar (status não 200)', () async {
      controller.emit(
        controller.state.copyWith(data: MeetingDataSource([])),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.deleteAgendamento('agend-123');
      expect(result, false);
      expect(controller.state.hasError, 'Erro ao excluir agendamento');
    });

    test('deve retornar false ao lançar Exception', () async {
      when(() => mockRepository.delete(any())).thenThrow(
        Exception('Falha de conexão'),
      );

      final result = await controller.deleteAgendamento('agend-123');
      expect(result, false);
      expect(controller.state.hasError.toString(), contains('Falha de conexão'));
    });
  });
}
