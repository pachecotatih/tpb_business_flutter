import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/config/user/user_controller.dart';
import 'package:tpb_business_flutter/features/config/user/user_model.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late UserController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'email': 'tatiana@test.com',
      'token': 'mock_token',
      'user': 'tatiana',
      'name': 'Tatiana',
      'moeda': 'R\$',
      'refreshToken': 'mock_refresh',
      'deviceId': 'mock_device_id',
    });
    await Preferences.instance.init();
    mockRepository = MockRepository();
    controller = UserController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('UserController - getUser', () {
    blocTest<UserController, dynamic>(
      'deve carregar dados do usuário ao retornar 200',
      build: () {
        when(() => mockRepository.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'name': 'Tatiana Pacheco Barreto',
              'email': 'tatiana@test.com',
              'telefone': '11999999999',
              'documento': '123.456.789-00',
              'moeda': 'R\$',
            },
            statusCode: 200,
          ),
        );
        return controller;
      },
      act: (c) => c.getUser(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
        expect(c.state.data!.name, 'Tatiana Pacheco Barreto');
        expect(c.state.data!.email, 'tatiana@test.com');
        expect(c.state.data!.moeda, 'R\$');
      },
    );

    blocTest<UserController, dynamic>(
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
      act: (c) => c.getUser(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.hasError,
              'hasError',
              'Erro interno ao obter usuário',
            ),
      ],
    );

    blocTest<UserController, dynamic>(
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
      act: (c) => c.getUser(),
      expect: () => [
        isA<dynamic>().having((s) => s.isLoading, 'isLoading', true),
        isA<dynamic>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasError, 'hasError', 'Erro ao obter usuário'),
      ],
    );
  });

  group('UserController - updateUser', () {
    test(
      'deve retornar true e atualizar preferências ao receber 200',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: UserModel(
              name: 'Tatiana Nova',
              email: 'nova@test.com',
              moeda: 'US\$',
              telefone: '11988888888',
              documento: '111.222.333-44',
            ),
          ),
        );

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'name': 'Tatiana Nova',
              'email': 'nova@test.com',
              'telefone': '11988888888',
              'documento': '111.222.333-44',
              'moeda': 'US\$',
            },
            statusCode: 200,
          ),
        );

        final result = await controller.updateUser();
        expect(result, true);
        expect(Preferences.instance.name, 'Tatiana Nova');
        expect(Preferences.instance.email, 'nova@test.com');
        expect(Preferences.instance.moeda, 'US\$');
      },
    );

    test(
      'deve retornar false e emitir erro de validação ao receber 422',
      () async {
        controller.emit(controller.state.copyWith(data: UserModel()));

        when(() => mockRepository.put(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'errors': 'E-mail inválido'},
            statusCode: 422,
          ),
        );

        final result = await controller.updateUser();
        expect(result, false);
        expect(controller.state.hasError, 'E-mail inválido');
      },
    );

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(controller.state.copyWith(data: UserModel()));

      when(() => mockRepository.put(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.updateUser();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao atualizar usuário');
    });
  });

  group('UserController - changePasswordUser', () {
    test(
      'deve retornar true ao alterar senha com sucesso quando senhas conferem',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: UserModel(
              password: 'nova_senha_123',
              confirmPassword: 'nova_senha_123',
            ),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'name': 'Tatiana',
              'email': 'tatiana@test.com',
              'telefone': '11999999999',
              'documento': '123',
              'moeda': 'R\$',
            },
            statusCode: 200,
          ),
        );

        final result = await controller.changePasswordUser();
        expect(result, true);
      },
    );

    test(
      'deve retornar false e emitir erro de validação quando senhas não conferem',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: UserModel(password: 'senha_a', confirmPassword: 'senha_b'),
          ),
        );

        final result = await controller.changePasswordUser();
        expect(result, false);
        expect(controller.state.hasError, 'Senhas não conferem');
        verifyNever(() => mockRepository.post(any(), any()));
      },
    );

    test('deve retornar false quando senha estiver vazia', () async {
      controller.emit(
        controller.state.copyWith(
          data: UserModel(password: '', confirmPassword: ''),
        ),
      );

      final result = await controller.changePasswordUser();
      expect(result, false);
      expect(controller.state.hasError, 'Senhas não conferem');
    });

    test(
      'deve retornar false e emitir erro de validação ao receber 422',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: UserModel(password: 'curta', confirmPassword: 'curta'),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'errors': 'Senha deve ter no mínimo 8 caracteres'},
            statusCode: 422,
          ),
        );

        final result = await controller.changePasswordUser();
        expect(result, false);
        expect(
          controller.state.hasError,
          'Senha deve ter no mínimo 8 caracteres',
        );
      },
    );
  });

  group('UserController - deleteUser', () {
    test(
      'deve retornar true e limpar preferências ao excluir conta com sucesso (200)',
      () async {
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final result = await controller.deleteUser();
        expect(result, true);
        expect(Preferences.instance.token, '');
        expect(Preferences.instance.email, '');
      },
    );

    test(
      'deve retornar false e emitir erro interno ao falhar com 500',
      () async {
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );

        final result = await controller.deleteUser();
        expect(result, false);
        expect(controller.state.hasError, 'Erro interno ao excluir usuário');
      },
    );

    test(
      'deve retornar false e emitir erro genérico para status padrão',
      () async {
        when(() => mockRepository.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );

        final result = await controller.deleteUser();
        expect(result, false);
        expect(controller.state.hasError, 'Erro ao excluir usuário');
      },
    );
  });
}
