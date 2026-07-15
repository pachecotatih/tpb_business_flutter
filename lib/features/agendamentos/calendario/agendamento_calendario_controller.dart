import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/agendamentos/meetings_model.dart';

class AgendamentoCalendarioController
    extends BaseController<MeetingDataSource> {
  final Repository repository;

  AgendamentoCalendarioController(this.repository)
    : super(StateBloc<MeetingDataSource>(data: MeetingDataSource([])));

  Future<void> getAgendamentos() async {
    Response response;
    try {
      try {
        emit(state.copyWith(isLoading: true));
        response = await repository.get('${Globals.urlApi}/agendamento');
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter agendamentos. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          List<AgendamentoModel> agendamentos = (response.data as List)
              .map((e) => AgendamentoModel.fromJson(e))
              .toList();
          emit(
            state.copyWith(
              data: _getMeetingDataSource(agendamentos),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao obter agendamentos',
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: 'Erro ao obter agendamentos',
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e.toString(), isLoading: false));
    }
  }

  Future<bool> updateAgendamentos(Meeting meeting) async {
    try {
      Response response;
      try {
        response = await repository
            .put('${Globals.urlApi}/agendamento/${meeting.uid}', {
              'status': meeting.status,
              'data_inicio': meeting.from.toString(),
              'data_fim': meeting.to.toString(),
              'cliente_id': meeting.clienteId,
              'forma_pagamento': meeting.formaPagamento,
              'valor_total': meeting.valorTotal,
              'servicos': meeting.servicos.map((e) => e.toJson()).toList(),
            });
      } on DioException catch (e) {
        throw Exception("Ocorreu um erro ao obter agendamentos. ${e.message}");
      }

      switch (response.statusCode) {
        case 200:
          emit(state.copyWith(isLoading: false));
          return true;
        case 500:
          emit(
            state.copyWith(
              hasError: 'Erro interno ao atualizar agendamento',
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
              hasError: 'Erro ao atualizar agendamento',
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

  MeetingDataSource _getMeetingDataSource(List<AgendamentoModel> agendamentos) {
    List<Meeting> meetings = <Meeting>[];

    for (var agendamento in agendamentos) {
      meetings.add(_getEvent(agendamento));
    }
    return MeetingDataSource(meetings);
  }

  Meeting _getEvent(AgendamentoModel agendamento) {
    DateTime dataInicio = DateTime.now();
    DateTime dataFim = DateTime.now();

    if (agendamento.dataInicio != null) {
      dataInicio = DateTime.parse(agendamento.dataInicio!);
    }
    if (agendamento.dataFim != null) {
      dataFim = DateTime.parse(agendamento.dataFim!);
    }
    return Meeting(
      eventName: agendamento.cliente?.nome ?? 'Sem nome',
      clienteId: agendamento.cliente?.id ?? 0,
      from: dataInicio,
      to: dataFim,
      cliente: agendamento.cliente,
      observacao: agendamento.observacao ?? '',
      status: agendamento.status ?? 'pendente',
      servicos: agendamento.servicos ?? [],
      valorTotal: agendamento.valorTotal ?? 0.0,
      uid: agendamento.uid ?? '',
      background: agendamento.status == 'cancelado'
          ? Cores.negativeColor
          : (agendamento.status == 'concluido'
                ? Cores.positiveColor
                : Cores.secondaryText),
    );
  }
}
