import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class AgendamentoItemController extends BaseController<AgendamentoModel> {
  final Repository repository;

  AgendamentoItemController(this.repository)
    : super(StateBloc(data: AgendamentoModel()));

  Future<void> get(String uid) async {
    if (uid.isNotEmpty) {
      Response response;
      try {
        emit(state.copyWith(isLoading: true));
        try {
          response = await repository.get('${Globals.urlApi}/agendamento/$uid');
        } on DioException catch (e) {
          throw Exception("Ocorreu um erro ao obter agendamento. ${e.message}");
        }

        switch (response.statusCode) {
          case 200:
            emit(
              state.copyWith(
                data: AgendamentoModel.fromJson(response.data),
                isLoading: false,
              ),
            );
            await _getClientes();
            if (state.hasError != null) return;
            await _getServicos();
            break;
          case 500:
            emit(
              state.copyWith(
                hasError: 'Erro interno ao obter agendamento',
                isLoading: false,
              ),
            );
            break;
          default:
            emit(
              state.copyWith(
                hasError: 'Erro ao obter agendamento',
                isLoading: false,
              ),
            );
            break;
        }
      } catch (e) {
        emit(state.copyWith(hasError: e.toString(), isLoading: false));
      }
    } else {
      emit(state.copyWith(data: AgendamentoModel(), isLoading: false));
      await _getClientes();
      if (state.hasError != null) return;
      await _getServicos();
    }
  }

  Future<void> _getClientes() async {
    Response response;
    state.data!.loadingClientes = true;
    emit(state.copyWith(data: state.data));
    try {
      try {
        response = await repository.get('${Globals.urlApi}/cliente');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter clientes. ${e.message}");
      }
      switch (response.statusCode) {
        case 200:
          AgendamentoModel agendamento = state.data!;
          agendamento.clientes = (response.data as List)
              .map((e) => ClienteModel.fromJson(e))
              .toList();
          agendamento.loadingClientes = false;
          emit(state.copyWith(data: agendamento, isLoading: false));
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

  Future<void> _getServicos() async {
    Response response;
    state.data!.loadingServicos = true;
    emit(state.copyWith(data: state.data));
    try {
      try {
        response = await repository.get('${Globals.urlApi}/servico');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter serviços. ${e.message}");
      }
      switch (response.statusCode) {
        case 200:
          AgendamentoModel agendamento = state.data!;
          agendamento.servicosInit = (response.data as List)
              .map((e) => ServicoModel.fromJson(e))
              .toList();
          agendamento.loadingServicos = false;
          emit(state.copyWith(data: agendamento, isLoading: false));
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

  Future<bool> save() async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        if ((state.data!.uid ?? '').isNotEmpty) {
          response = await repository.put(
            '${Globals.urlApi}/agendamento/${state.data!.uid}',
            state.data!.toJson(),
          );
        } else {
          state.data!.status = 'agendado';
          response = await repository.post(
            '${Globals.urlApi}/agendamento',
            state.data!.toJson(),
          );
        }
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao salvar agendamento. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          emit(
            state.copyWith(
              data: AgendamentoModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao salvar agendamento',
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
              hasError: 'Erro ao salvar agendamento',
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
        response = await repository.delete(
          '${Globals.urlApi}/agendamento/${state.data!.uid}',
        );
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao excluir agendamento. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(data: null, isLoading: false));
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao excluir agendamento',
              isLoading: false,
            ),
          );
          return false;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao excluir agendamento',
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
