import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/componentes/arrow_icon.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/componentes/filters.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/componentes/saldo_atual_card.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/lista/fluxo_caixa_lista_controller.dart';

class FluxoCaixaListaPage extends StatefulWidget {
  const FluxoCaixaListaPage({super.key});

  @override
  State<FluxoCaixaListaPage> createState() => _FluxoCaixaListaPageState();
}

class _FluxoCaixaListaPageState extends State<FluxoCaixaListaPage> {
  @override
  void initState() {
    super.initState();
    _callGetFluxoCaixa();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemePage(
      title: 'Fluxo de Caixa',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushReplacement('/fluxocaixa/new');
        },
        backgroundColor: Cores.positiveColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      children: [
        BlocConsumer<FluxoCaixaListaController, StateBloc<FluxoCaixaModel>>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                SaldoAtualCard(
                  saldo: state.data?.saldo ?? 0,
                  entrada: state.data?.totalEntradas ?? 0,
                  saida: state.data?.totalSaidas ?? 0,
                ),
                MovimentacaoFilter(
                  onFilterTodos: () async {
                    _callGetFluxoCaixa(
                        dataRegistroFim: state.data?.dataFim ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString()), 
                        dataRegistroInicio: state.data?.dataInicio ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month, 1).toString())
                    );
                  },
                  onFilterEntrada: () async {
                    _callGetFluxoCaixa(
                        dataRegistroFim: state.data?.dataFim ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString()), 
                        dataRegistroInicio: state.data?.dataInicio ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month, 1).toString()),
                        tipoMovimentacao: 'entrada',
                        movimentacaoEscolhida: 'Entrada'
                    );
                  },
                  onFilterSaida: () async {
                    _callGetFluxoCaixa(
                        dataRegistroFim: state.data?.dataFim ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString()), 
                        dataRegistroInicio: state.data?.dataInicio ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month, 1).toString()),
                        tipoMovimentacao: 'saida',
                        movimentacaoEscolhida: 'Saída'
                    );
                  }, movimentacaoEscolhida: state.data!.movimentacaoEscolhida,
                ),
                DataFilter(
                  dataFim: state.data?.dataFim ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString()),
                  dataInicio: state.data?.dataInicio ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month, 1).toString()),
                  onFilterFim: (value) => _callGetFluxoCaixa(
                    dataRegistroFim:  DateFormat('yyyy-MM-dd HH:mm:ss').format(value), 
                    dataRegistroInicio: state.data?.dataInicio ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month, 1).toString()),
                    tipoMovimentacao: (state.data!.movimentacaoEscolhida == 'Saída') ? 'saida' : state.data!.movimentacaoEscolhida.toLowerCase(),
                    movimentacaoEscolhida: state.data!.movimentacaoEscolhida
                    ),
                  onFilterInicio: (value) => _callGetFluxoCaixa(
                    dataRegistroInicio:  DateFormat('yyyy-MM-dd HH:mm:ss').format(value), 
                    dataRegistroFim: state.data?.dataFim ?? Util.dateFormatString(DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString()),
                    tipoMovimentacao: (state.data!.movimentacaoEscolhida == 'Saída') ? 'saida' : state.data!.movimentacaoEscolhida.toLowerCase(),
                    movimentacaoEscolhida: state.data!.movimentacaoEscolhida
                    ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.data?.grupos?.length ?? 0,
                  itemBuilder: (context, index) {
                    FluxoCaixaGrupoModel grupo = state.data!.grupos![index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: TextoPadrao(
                            text: DateFormat.yMMMd(
                              'pt_BR',
                            ).format(grupo.data),
                          ),
                        ),
                        Bloco(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: grupo.fluxoCaixaList.length,
                            itemBuilder: (context, index) {
                              FluxoCaixaItemModel fluxoCaixa =
                                  grupo.fluxoCaixaList[index];
                              return ListTile(
                                onTap: () => context.pushReplacement(
                                  '/fluxocaixa/${fluxoCaixa.uid}',
                                ),
                                title: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  runSpacing: 10,
                                  spacing: 10,
                                  children: [
                                    ArrowIcon(
                                      icon:
                                          fluxoCaixa.tipoMovimentacao ==
                                              'entrada'
                                          ? Icons.arrow_upward_sharp
                                          : Icons.arrow_downward_sharp,
                                      color1:
                                          fluxoCaixa.tipoMovimentacao ==
                                              'entrada'
                                          ? Cores.positiveColor.withValues(
                                              alpha: 0.2,
                                            )
                                          : Cores.negativeColor.withValues(
                                              alpha: 0.2,
                                            ),
                                      color2:
                                          fluxoCaixa.tipoMovimentacao ==
                                              'entrada'
                                          ? Cores.positiveColor
                                          : Cores.negativeColor,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(fluxoCaixa.descricao ?? ''),
                                        Text(
                                          fluxoCaixa.tipoMovimentacao ==
                                                  'entrada'
                                              ? 'Pago em ${Util.dateFormatString(fluxoCaixa.dataPagamento!)}'
                                              : 'Vence em ${Util.dateFormatString(fluxoCaixa.dataVencimento!)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Cores.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '${Preferences.instance.moeda}${Util.stringFormatValor(fluxoCaixa.valor ?? 0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        fluxoCaixa.tipoMovimentacao ==
                                            'entrada'
                                        ? Cores.positiveColor
                                        : Cores.negativeColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
          listener: (context, state) {
            if (state.hasError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.hasError!.toString()),
                  backgroundColor: Cores.negativeColor,
                ),
              );
            }
          },
        ),
      ],
    );
  }
  Future<void> _callGetFluxoCaixa({
  String? tipoMovimentacao,
  String? dataRegistroInicio,
  String? dataRegistroFim,
  String? formaPagamento,
  String movimentacaoEscolhida="Todos",
}) async {
  final inicio = dataRegistroInicio ??
      DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime(DateTime.now().year, DateTime.now().month, 1),
      );

  final fim = dataRegistroFim ??
      DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
      );

  await context.read<FluxoCaixaListaController>().getFluxoCaixa(
        formaPagamento: formaPagamento,
        tipoMovimentacao: tipoMovimentacao,
        dataRegistroInicio: inicio,
        dataRegistroFim: fim,
        movimentacaoEscolhida: movimentacaoEscolhida,
      );
}
}
