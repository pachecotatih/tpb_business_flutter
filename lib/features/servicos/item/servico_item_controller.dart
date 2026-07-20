import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class ServicoItemController extends BaseController<ServicoModel> {
  final Repository repository;

  ServicoItemController(this.repository)
    : super(StateBloc<ServicoModel>(data: ServicoModel()));

  Future<void> get(String uid) async {
    if (uid.isNotEmpty) {
      try {
        Response response;
        emit(state.copyWith(isLoading: true));
        try {
          response = await repository.get('${Globals.urlApi}/servico/$uid');
        } on DioException catch (e) {
          throw Exception("Ocorreu um erro ao obter serviço. ${e.message}");
        }

        switch (response.statusCode) {
          case 200:
            emit(
              state.copyWith(
                data: ServicoModel.fromJson(response.data),
                isLoading: false,
              ),
            );
            break;
          case 500:
            emit(
              state.copyWith(
                hasError: 'Erro interno ao obter serviço',
                isLoading: false,
              ),
            );
            break;
          default:
            emit(
              state.copyWith(
                hasError: 'Erro ao obter serviço',
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
        if (state.data!.uid.isNotEmpty) {
          response = await repository.put(
            '${Globals.urlApi}/servico/${state.data!.uid}',
            state.data!.toJson(),
          );
        } else {
          response = await repository.post(
            '${Globals.urlApi}/servico',
            state.data!.toJson(),
          );
        }
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao salvar serviço. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          emit(
            state.copyWith(
              data: ServicoModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          return true;
        case 422:
          emit(
            state.copyWith(hasError: response.data['errors'], isLoading: false),
          );
          return false;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao salvar serviço',
              isLoading: false,
            ),
          );
          return false;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao salvar serviço',
              isLoading: false,
            ),
          );
          return false;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
      return false;
    }
  }

  Future<bool> delete() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.delete(
          '${Globals.urlApi}/servico/${state.data!.uid}',
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao excluir serviço. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: null, isLoading: false));
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir serviço',
              isLoading: false,
            ),
          );
          return false;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir serviço',
              isLoading: false,
            ),
          );
          return false;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
      return false;
    }
  }
}
