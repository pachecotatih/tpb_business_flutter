import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';

class ClienteListaController extends Cubit<StateBloc<List<ClienteModel>>> {
  final Repository repository;
  ClienteListaController(this.repository)
    : super(StateBloc<List<ClienteModel>>(data: []));

  Future<void> getClientes() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        response = await repository.get('${Globals.urlApi}/cliente');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter clientes. ${e.message}");
      }
      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: (response.data as List)
                  .map((e) => ClienteModel.fromJson(e))
                  .toList(),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao obter clientes',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao obter clientes',
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
        response = await repository.delete('${Globals.urlApi}/cliente/$uid');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao excluir cliente. ${e.message}");
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
  }
}
