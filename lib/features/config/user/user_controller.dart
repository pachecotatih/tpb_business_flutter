import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/config/user/user_model.dart';

class UserController extends BaseController<UserModel> {
  final Repository repository;

  UserController(this.repository)
    : super(StateBloc<UserModel>(data: UserModel()));

  Future<void> getUser() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.get('${Globals.urlApi}/user');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter usuário. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: UserModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao obter usuário',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(hasError: 'Erro ao obter usuário', isLoading: false),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
  }

  Future<bool> updateUser() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.put(
          '${Globals.urlApi}/user',
          state.data!.toJson(),
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao atualizar usuário. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: UserModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          await Preferences.instance.setName(state.data!.name);
          await Preferences.instance.setMoeda(state.data!.moeda);
          await Preferences.instance.setEmail(state.data!.email);
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao atualizar usuário',
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
              hasError: 'Erro ao atualizar usuário',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
    return false;
  }

  Future<bool> changePasswordUser() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    if (state.data!.password.isNotEmpty &&
        (state.data!.confirmPassword ?? '').isNotEmpty &&
        state.data!.password == state.data!.confirmPassword) {
      try {
        try {
          response = await repository.post(
            '${Globals.urlApi}/user/change-password',
            state.data!.toJson(),
          );
        } on DioException catch (e) {
          throw Exception(
            "Ocorreu um erro ao alterar a senha do usuário. ${e.message}",
          );
        }

        switch (response.statusCode) {
          case 200:
            emit(
              state.copyWith(
                data: UserModel.fromJson(response.data),
                isLoading: false,
              ),
            );
            return true;
          case 500:
            emit(
              state.copyWith(
                hasError: 'Erro interno ao alterar a senha do usuário',
                isLoading: false,
              ),
            );
            break;
          case 422:
            emit(
              state.copyWith(
                hasError: response.data['errors'],
                isLoading: false,
              ),
            );
            break;
          default:
            emit(
              state.copyWith(
                hasError: 'Erro ao alterar a senha do usuário',
                isLoading: false,
              ),
            );
            break;
        }
      } catch (e) {
        emit(state.copyWith(hasError: e, isLoading: false));
      }
    } else {
      emit(state.copyWith(hasError: 'Senhas não conferem', isLoading: false));
    }
    return false;
  }

  Future<bool> deleteUser() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      response = await repository.delete('${Globals.urlApi}/user');

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: null, isLoading: false));
          await Preferences.clear();
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir usuário',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir usuário',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
    return false;
  }
}
