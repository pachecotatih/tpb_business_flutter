import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';

class ClienteItemController extends Cubit<StateBloc<ClienteModel>> {
  final Repository repository;

  ClienteItemController(this.repository) : super(StateBloc<ClienteModel>(data:ClienteModel()));
  
  Future<void> get(String uid) async {
    if(uid.isNotEmpty) {
      Response response;
      emit(state.copyWith(isLoading: true));
      try {
        try {
          response = await repository.get('${Globals.urlApi}/cliente/$uid');
        } on DioException catch (e) {
          throw Exception("Ocorreu um erro ao obter cliente. ${e.message}");
        }
        switch (response.statusCode) {
          case 200:
            emit(
              state.copyWith(
                data: ClienteModel.fromJson(response.data),
                isLoading: false,
              ),
            );
            break;
          case 500:
            emit(
              state.copyWith(
                hasError: 'Erro interno ao obter cliente',
                isLoading: false,
              ),
            );
            break;
          default:
            emit(
              state.copyWith(
                hasError: 'Erro ao obter cliente',
                isLoading: false,
              ),
            );
            break;
        }
      } catch (e) {
        emit(state.copyWith(hasError: e.toString(), isLoading: false));
      }
    }
  }

  Future<bool> save() async {
    Response response;
    emit(state.copyWith(isLoading: true));

    try {
      try {
        if(state.data!.uid.isNotEmpty) {
          response = await repository.put('${Globals.urlApi}/cliente/${state.data!.uid}', state.data!.toJson());
        } else {
          response = await repository.post('${Globals.urlApi}/cliente', state.data!.toJson());
        }
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao salvar cliente. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          emit(
            state.copyWith(
              data: ClienteModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao salvar cliente',
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
              hasError: 'Erro ao salvar cliente',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
    }
    return false;
  }

  Future<bool> delete() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.delete('${Globals.urlApi}/cliente/${state.data!.uid}');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao excluir cliente. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: null,
              isLoading: false,
            ),
          );
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir cliente',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir cliente',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
    }
    return false;
  }
}