import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_controller.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late ClienteItemController controller;

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
    controller = ClienteItemController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('ClienteItemController - get', () {
    blocTest<ClienteItemController, dynamic>(
      'deve carregar dados do cliente ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'id': 1,
              'uid': 'cli-1',
              'nome': 'Tatiana Pacheco',
              'email': 'tatiana@test.com',
              'telefone': '11999999999',
              'documento': '123.456.789-00',
              'data_nascimento': '1990-01-01',
              'tipo': 'PF',
            },
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.get('cli-1'),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.uid, 'cli-1');
        expect(c.state.data!.nome, 'Tatiana Pacheco');
        expect(c.state.data!.email, 'tatiana@test.com');
      },
    );

    blocTest<ClienteItemController, dynamic>(
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
      act: (c) => c.get('cli-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter cliente',
            ),
      ],
    );

    blocTest<ClienteItemController, dynamic>(
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
      act: (c) => c.get('cli-1'),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter cliente'),
      ],
    );

    test('não deve fazer requisição quando uid está vazio', () async {
      await controller.get('');
      verifyNever(() => mockRepository.get(any()));
    });
  });

  group('ClienteItemController - save', () {
    test(
      'deve enviar POST e retornar true ao criar novo cliente (uid vazio)',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: ClienteModel(uid: '', nome: 'Novo Cliente'),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'id': 3, 'uid': 'cli-3', 'nome': 'Novo Cliente'},
            statusCode: 201,
          ),
        );

        final result = await controller.save();
        expect(result, true);
        expect(controller.state.data!.uid, 'cli-3');
        verify(() => mockRepository.post(any(), any())).called(1);
      },
    );

    test(
      'deve enviar PUT e retornar true ao atualizar cliente existente',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: ClienteModel(uid: 'cli-1', nome: 'Atualizado'),
          ),
        );

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'id': 1, 'uid': 'cli-1', 'nome': 'Atualizado'},
            statusCode: 200,
          ),
        );

        final result = await controller.save();
        expect(result, true);
        expect(controller.state.data!.nome, 'Atualizado');
        verify(() => mockRepository.put(any(), any())).called(1);
      },
    );

    test(
      'deve retornar false e emitir erro de validação ao receber 422',
      () async {
        controller.emit(
          controller.state.copyWith(data: ClienteModel(uid: 'cli-1')),
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
      },
    );

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(data: ClienteModel(uid: 'cli-1')),
      );

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.save();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao salvar cliente');
    });

    test(
      'deve retornar false e emitir erro genérico para status padrão',
      () async {
        controller.emit(
          controller.state.copyWith(data: ClienteModel(uid: 'cli-1')),
        );

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );

        final result = await controller.save();
        expect(result, false);
        expect(controller.state.hasError, 'Erro ao salvar cliente');
      },
    );
  });

  group('ClienteItemController - delete', () {
    test(
      'deve retornar true e limpar dados ao excluir com sucesso (200)',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: ClienteModel(uid: 'cli-1', nome: 'Tatiana'),
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
        verify(() => mockRepository.delete(any())).called(1);
      },
    );

    test(
      'deve retornar false e emitir erro interno ao falhar com 500',
      () async {
        controller.emit(
          controller.state.copyWith(data: ClienteModel(uid: 'cli-1')),
        );

        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );

        final result = await controller.delete();
        expect(result, false);
        expect(controller.state.hasError, 'Erro interno ao excluir cliente');
      },
    );

    test(
      'deve retornar false e emitir erro genérico para status padrão',
      () async {
        controller.emit(
          controller.state.copyWith(data: ClienteModel(uid: 'cli-1')),
        );

        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        );

        final result = await controller.delete();
        expect(result, false);
        expect(controller.state.hasError, 'Erro ao excluir cliente');
      },
    );
  });
}
