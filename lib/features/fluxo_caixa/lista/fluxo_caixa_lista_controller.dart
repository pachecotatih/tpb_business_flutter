import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';

class FluxoCaixaListaController extends BaseController<FluxoCaixaModel> {
  final Repository repository;
  FluxoCaixaListaController(this.repository)
    : super(StateBloc(data: FluxoCaixaModel()));

  Future<void> getFluxoCaixa({
    String? formaPagamento,
    String? tipoMovimentacao,
    String? dataRegistroInicio,
    String? dataRegistroFim,
  }) async {
    Response response;
    emit(state.copyWith(isLoading: true));
    try {
      try {
        String url = '${Globals.urlApi}/fluxocaixa';
        List params = [];
        if (formaPagamento != null && formaPagamento != 'todas') {
          params.add('forma_pagamento=$formaPagamento');
        }
        if (tipoMovimentacao != null && tipoMovimentacao != 'todos') {
          params.add('tipo_movimentacao=$tipoMovimentacao');
        }
        if (dataRegistroInicio != null) {
          params.add('data_registro_inicio=$dataRegistroInicio');
        }
        if (dataRegistroFim != null) {
          params.add('data_registro_fim=$dataRegistroFim');
        }
        if (params.isNotEmpty) {
          url = '$url?${params.join('&')}';
        }
        response = await repository.get(url);
      } on DioException catch (e) {
        throw Exception(
          "Ocorreu um erro ao obter fluxo de caixa. ${e.message}",
        );
      }
      switch (response.statusCode) {
        case 200:
          FluxoCaixaModel fluxoCaixa = FluxoCaixaModel.fromJson(response.data);
          fluxoCaixa.grupos = getGrupos(fluxoCaixa.fluxoCaixaList);
          fluxoCaixa.tipoMovimentacao = tipoMovimentacao;
          fluxoCaixa.dataInicio = dataRegistroInicio;
          fluxoCaixa.dataFim = dataRegistroFim;
          fluxoCaixa.formaPagamento = formaPagamento;
          emit(state.copyWith(data: fluxoCaixa, isLoading: false));

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
      emit(state.copyWith(hasError: e, isLoading: false));
    }
  }

  List<FluxoCaixaGrupoModel> getGrupos(
    List<FluxoCaixaItemModel>? fluxoCaixaList,
  ) {
    if (fluxoCaixaList != null && fluxoCaixaList.isNotEmpty) {
      final map = <String, List<FluxoCaixaItemModel>>{};
      fluxoCaixaList.sort(
        (a, b) => DateTime.parse(
          b.createdAt!,
        ).compareTo(DateTime.parse(a.createdAt!)),
      );
      for (final item in (fluxoCaixaList)) {
        final data = item.createdAt!.substring(0, 10);
        map.putIfAbsent(data, () => []);
        map[data]!.add(item);
      }

      return map.entries.map((e) {
        return FluxoCaixaGrupoModel(
          data: DateTime.parse(e.key),
          fluxoCaixaList: e.value,
        );
      }).toList();
    }
    return [];
  }
}
