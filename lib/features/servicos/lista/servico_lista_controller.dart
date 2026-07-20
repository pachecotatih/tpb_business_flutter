import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class ServicoListaController extends BaseController<List<ServicoModel>> {
  final Repository repository;
  final ValueNotifier<String> busca = ValueNotifier<String>('');

  ServicoListaController(this.repository)
    : super(StateBloc<List<ServicoModel>>(data: [])) {
    busca.addListener(() async {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(isLoading: false, data: state.data));
    });
  }

  @override
  Future<void> close() {
    busca.dispose();
    return super.close();
  }

  Future<void> getServicos() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.get('${Globals.urlApi}/servico');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter serviços. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: (response.data as List)
                  .map((e) => ServicoModel.fromJson(e))
                  .toList(),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao obter serviços',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao obter serviços',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
    }
  }

  Future<void> delete(String uid) async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.delete('${Globals.urlApi}/servico/$uid');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao excluir serviço. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: state.data!.where((element) => element.uid != uid).toList(),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir serviço',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir serviço',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
    }
  }

  Future<bool> updateAtivo(String uid, bool ativo) async {
    emit(
      state.copyWith(data: atualizarAtivoLista(ativo, uid), isLoading: false),
    );
    Response response;
    try {
      try {
        response = await repository.put(
          '${Globals.urlApi}/servico/$uid/ativo',
          {'ativo': ativo},
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter serviços. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao alterar o ativo do serviço',
              isLoading: false,
              data: atualizarAtivoLista(!ativo, uid),
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao alterar o ativo do serviço',
              data: atualizarAtivoLista(!ativo, uid),
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(
        state.copyWith(
          hasError: e.toString(),
          isLoading: false,
          data: atualizarAtivoLista(!ativo, uid),
        ),
      );
    }
    return false;
  }

  List<ServicoModel> atualizarAtivoLista(bool novoValorAtivo, String uid) {
    return state.data!.map((e) {
      if (e.uid == uid) {
        final copia = ServicoModel.fromJson(e.toJson());
        copia.ativo = novoValorAtivo;
        return copia;
      }
      return e;
    }).toList();
  }
}
