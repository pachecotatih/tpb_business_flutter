import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/servicos/item/servico_item_controller.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late ServicoItemController controller;

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
    controller = ServicoItemController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('ServicoItemController - get', () {
    blocTest<ServicoItemController, dynamic>(
      'deve carregar detalhes do serviço ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'uid': 's1',
              'nome': 'Corte de Cabelo',
              'valor_padrao': 50.0,
              'duracao_padrao': '01:00',
              'ativo': true,
            },
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.get('s1'),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.uid, 's1');
        expect(c.state.data!.nome, 'Corte de Cabelo');
        expect(c.state.data!.valorPadrao, 50.0);
        expect(c.state.data!.duracaoPadrao, '01:00');
        expect(c.state.data!.ativo, true);
      },
    );

    blocTest<ServicoItemController, dynamic>(
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
      act: (c) => c.get('s1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro interno ao obter serviço'),
      ],
    );

    blocTest<ServicoItemController, dynamic>(
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
      act: (c) => c.get('s1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter serviço'),
      ],
    );

    test('não deve fazer requisição quando uid está vazio', () async {
      await controller.get('');
      verifyNever(() => mockRepository.get(any()));
    });
  });

  group('ServicoItemController - save', () {
    test('deve enviar POST e retornar true ao criar novo serviço (uid vazio)', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: '', nome: 'Novo Serviço')),
      );

      when(() => mockRepository.post(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'uid': 's-new', 'nome': 'Novo Serviço', 'valor_padrao': 0, 'ativo': true},
          statusCode: 201,
        ),
      );

      final result = await controller.save();
      expect(result, true);
      expect(controller.state.data!.uid, 's-new');
      verify(() => mockRepository.post(any(), any())).called(1);
    });

    test('deve enviar PUT e retornar true ao editar serviço existente', () async {
      controller.emit(
        controller.state.copyWith(
          data: ServicoModel(uid: 's1', nome: 'Corte Editado', valorPadrao: 60.0),
        ),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'uid': 's1', 'nome': 'Corte Editado', 'valor_padrao': 60.0, 'ativo': true},
          statusCode: 200,
        ),
      );

      final result = await controller.save();
      expect(result, true);
      expect(controller.state.data!.nome, 'Corte Editado');
      verify(() => mockRepository.put(any(), any())).called(1);
    });

    test('deve retornar false e emitir erro de validação ao receber 422', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: 's1')),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'errors': 'Nome é obrigatório'},
          statusCode: 422,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Nome é obrigatório');
    });

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: 's1')),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao salvar serviço');
    });

    test('deve retornar false e emitir erro genérico para status padrão', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: 's1')),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro ao salvar serviço');
    });
  });

  group('ServicoItemController - delete', () {
    test('deve retornar true e limpar data ao excluir com sucesso (200)', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: 's1', nome: 'Corte de Cabelo')),
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
        controller.state.copyWith(data: ServicoModel(uid: 's1')),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao excluir serviço');
    });

    test('deve retornar false e emitir erro genérico para status padrão', () async {
      controller.emit(
        controller.state.copyWith(data: ServicoModel(uid: 's1')),
      );

      when(() => mockRepository.delete(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );

      final result = await controller.delete();
      expect(result, false);
      expect(controller.state.hasError, 'Erro ao excluir serviço');
    });
  });
}
