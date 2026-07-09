import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/login/login_model.dart';

class LoginController extends BaseController<LoginModel> {
  final Repository repository;
  LoginController(this.repository)
    : super(StateBloc<LoginModel>(data: LoginModel()));

  Future<bool> login() async {
    Response response;
    try {
      emit(state.copyWith(isLoading: true, hasError: null, data: state.data!));
      String deviceId = Util.getDeviceId();
      String deviceName = Util.getDeviceName();
      state.data!.deviceId = deviceId;
      state.data!.deviceName = deviceName;
      try {
        response = await repository.post(
          '${Globals.urlApi}/login',
          state.data!.toJson(),
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao efetuar login. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: state.data, isLoading: false));
          Preferences.instance.setToken(response.data['access_token']);
          Preferences.instance.setRefreshToken(response.data['refresh_token']);
          Preferences.instance.setUser(response.data['user']);
          Preferences.instance.setName(response.data['name']);
          Preferences.instance.setMoeda(response.data['moeda'] ?? "R\$");
          Preferences.instance.setEmail(response.data['email']);
          Preferences.instance.setDeviceId(response.data['device_id']);
          return true;
        case 401:
          emit(
            state.copyWith(hasError: 'Credenciais inválidas', isLoading: false),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao efetuar login',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(hasError: 'Erro ao efetuar login', isLoading: false),
          );
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
    return false;
  }

  Future<bool> cadastrar() async {
    Response response;
    try {
      emit(state.copyWith(isLoading: true, hasError: null, data: state.data!));
      try {
        response = await repository.post(
          '${Globals.urlApi}/register',
          state.data!.toJson(),
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao efetuar cadastro. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          emit(state.copyWith(data: state.data, isLoading: false));
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao efetuar cadastro',
              isLoading: false,
            ),
          );
          break;
        case 422:
          emit(
            state.copyWith(hasError: response.data['errors'], isLoading: false),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao efetuar cadastro',
              isLoading: false,
            ),
          );
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
    return false;
  }

  Future<bool> logout() async {
    Response response;
    try {
      emit(state.copyWith(isLoading: true, hasError: null, data: state.data!));
      try {
        response = await repository.post('${Globals.urlApi}/logout', {
          'email': Preferences.instance.email,
          'device_id': Preferences.instance.deviceId,
        });
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao efetuar logout. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: state.data, isLoading: false));
          await Preferences.clear();
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao efetuar logout',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao efetuar logout',
              isLoading: false,
            ),
          );
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
    return false;
  }
}
