import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_model.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late LoginController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'email': '',
      'token': '',
      'user': '',
      'name': '',
      'moeda': 'R\$',
      'refreshToken': '',
      'deviceId': '',
    });
    await Preferences.instance.init();
    mockRepository = MockRepository();
    controller = LoginController(mockRepository);
  });

  tearDown(() {
    controller.close();
  });

  group('LoginController - login', () {
    test(
      'deve retornar true e salvar preferências ao efetuar login com sucesso (200)',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: LoginModel(email: 'tatiana@test.com', password: 'senha123'),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'access_token': 'jwt_token_abc',
              'refresh_token': 'refresh_abc',
              'user': 'tatiana',
              'name': 'Tatiana Pacheco',
              'moeda': 'R\$',
              'email': 'tatiana@test.com',
              'device_id': 'dev-001',
            },
            statusCode: 200,
          ),
        );

        final result = await controller.login();
        expect(result, true);
        expect(Preferences.instance.token, 'jwt_token_abc');
        expect(Preferences.instance.email, 'tatiana@test.com');
        expect(Preferences.instance.name, 'Tatiana Pacheco');
      },
    );

    test(
      'deve retornar false e emitir credenciais inválidas ao receber 400',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: LoginModel(
              email: 'tatiana@test.com',
              password: 'senha_errada',
            ),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );

        final result = await controller.login();
        expect(result, false);
        expect(controller.state.hasError, 'Credenciais inválidas');
      },
    );

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(
          data: LoginModel(email: 'tatiana@test.com', password: 'senha123'),
        ),
      );

      when(() => mockRepository.post(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.login();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao efetuar login');
    });

    test(
      'deve retornar false e emitir erro genérico para status padrão',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: LoginModel(email: 'tatiana@test.com', password: 'senha123'),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
        );

        final result = await controller.login();
        expect(result, false);
        expect(controller.state.hasError, 'Erro ao efetuar login');
      },
    );
  });

  group('LoginController - cadastrar', () {
    blocTest<LoginController, dynamic>(
      'deve retornar true ao cadastrar novo usuário com sucesso (201)',
      build: () {
        controller.emit(
          controller.state.copyWith(
            data: LoginModel(
              name: 'Novo Usuário',
              email: 'novo@test.com',
              password: 'senha123',
            ),
          ),
        );
        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 201,
          ),
        );
        return controller;
      },
      act: (c) => c.cadastrar(),
      verify: (c) {
        expect(c.state.isLoading, false);
        expect(c.state.hasError, null);
      },
    );

    test(
      'deve retornar false e emitir erro de validação ao receber 422',
      () async {
        controller.emit(
          controller.state.copyWith(
            data: LoginModel(email: 'novo@test.com', password: '123'),
          ),
        );

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'errors': 'O campo name é obrigatório'},
            statusCode: 422,
          ),
        );

        final result = await controller.cadastrar();
        expect(result, false);
        expect(controller.state.hasError, 'O campo name é obrigatório');
      },
    );

    test('deve retornar false e emitir erro interno ao receber 500', () async {
      controller.emit(
        controller.state.copyWith(
          data: LoginModel(
            name: 'User',
            email: 'novo@test.com',
            password: '123',
          ),
        ),
      );

      when(() => mockRepository.post(any(), any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );

      final result = await controller.cadastrar();
      expect(result, false);
      expect(controller.state.hasError, 'Erro interno ao efetuar cadastro');
    });
  });

  group('LoginController - logout', () {
    test(
      'deve retornar true e limpar preferências ao fazer logout com sucesso (200)',
      () async {
        SharedPreferences.setMockInitialValues({
          'email': 'tatiana@test.com',
          'token': 'some_token',
          'user': 'tatiana',
          'name': 'Tatiana',
          'moeda': 'R\$',
          'refreshToken': 'refresh',
          'deviceId': 'dev-001',
        });
        await Preferences.instance.init();

        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final result = await controller.logout();
        expect(result, true);
        
        // As preferências devem ser limpas
        expect(Preferences.instance.token, '');
        expect(Preferences.instance.email, '');
      },
    );

    test(
      'deve retornar false e emitir erro interno ao receber 500 no logout',
      () async {
        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );

        final result = await controller.logout();
        expect(result, false);
        expect(controller.state.hasError, 'Erro interno ao efetuar logout');
      },
    );

    test(
      'deve retornar false e emitir erro genérico para status padrão no logout',
      () async {
        when(() => mockRepository.post(any(), any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );

        final result = await controller.logout();
        expect(result, false);
        expect(controller.state.hasError, 'Erro ao efetuar logout');
      },
    );
  });
}
