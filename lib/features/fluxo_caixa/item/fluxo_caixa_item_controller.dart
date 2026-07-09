import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';

class FluxoCaixaItemController extends BaseController<FluxoCaixaItemModel> {
  final Repository repository;

  FluxoCaixaItemController(this.repository)
    : super(StateBloc<FluxoCaixaItemModel>(data: FluxoCaixaItemModel()));

  Future<void> get(String uid) async {
    if (uid.isNotEmpty) {
      Response response;
      emit(state.copyWith(isLoading: true));
      try {
        try {
          response = await repository.get('${Globals.urlApi}/fluxocaixa/$uid');
        } on DioException catch (e) {
          throw Exception(
            "Ocorreu um erro ao obter fluxo de caixa. ${e.message}",
          );
        }
        switch (response.statusCode) {
          case 200:
            emit(
              state.copyWith(
                data: FluxoCaixaItemModel.fromJson(response.data),
                isLoading: false,
              ),
            );
            break;
          case 500:
            emit(
              state.copyWith(
                hasError: 'Erro interno ao obter fluxo de caixa',
                isLoading: false,
              ),
            );
            break;
          default:
            emit(
              state.copyWith(
                hasError: 'Erro ao obter fluxo de caixa',
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
        if ((state.data!.uid ?? '').isEmpty) {
          response = await repository.post(
            '${Globals.urlApi}/fluxocaixa',
            state.data!.toJson(),
          );
        } else {
          response = await repository.put(
            '${Globals.urlApi}/fluxocaixa/${state.data!.uid!}',
            state.data!.toJson(),
          );
        }
      } on DioException catch (e) {
        throw Exception(
          "Ocorreu um erro ao salvar fluxo de caixa. ${e.message}",
        );
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          emit(
            state.copyWith(
              data: FluxoCaixaItemModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          return true;
        case 422:
          emit(
            state.copyWith(hasError: response.data['errors'], isLoading: false),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao salvar fluxo de caixa',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao salvar fluxo de caixa',
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
    try {
      try {
        response = await repository.delete(
          '${Globals.urlApi}/fluxocaixa/${state.data!.uid}',
        );
      } on DioException catch (e) {
        throw Exception(
          "Ocorreu um erro ao excluir fluxo de caixa. ${e.message}",
        );
      }
      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: null, isLoading: false));
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir fluxo de caixa',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir fluxo de caixa',
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
