import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/money_input_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/fluxo_caixa_model.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/item/fluxo_caixa_item_controller.dart';

class FluxoCaixaItemPage extends StatefulWidget {
  final String uid;
  const FluxoCaixaItemPage({super.key, required this.uid});

  @override
  State<FluxoCaixaItemPage> createState() => _FluxoCaixaItemPageState();
}

class _FluxoCaixaItemPageState extends State<FluxoCaixaItemPage> {
  @override
  void initState() {
    super.initState();
    if (widget.uid.isNotEmpty) {
      context.read<FluxoCaixaItemController>().get(widget.uid);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      FluxoCaixaItemController,
      StateBloc<FluxoCaixaItemModel>
    >(
      builder: (context, state) {
        return ThemePage(
          title: (widget.uid.isNotEmpty)
              ? 'Editar Fluxo de Caixa'
              : 'Novo Fluxo de Caixa',
          bottomAppBarItems: [
            if (widget.uid.isNotEmpty)
              BottomButton(
                icon: Icons.delete,
                label: 'Excluir',
                color: Cores.negativeColor,
                onPressed: () async {
                  _deleteFluxoCaixa(context);
                },
              ),
          ],
          floatingActionButton: FloatingActionButton(
            backgroundColor: Cores.positiveColor,
            foregroundColor: Colors.white,
            onPressed: () async {
              bool result = await context
                  .read<FluxoCaixaItemController>()
                  .save();
              if (result) appRouter.pushReplacement('/fluxocaixa');
            },
            child: const Icon(Icons.check),
          ),
          children: [
            BlocBuilder<
              FluxoCaixaItemController,
              StateBloc<FluxoCaixaItemModel>
            >(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Bloco(
                  child: Column(
                    children: [
                      CampoSelectComponent<String>(
                        label: 'Tipo de movimentação',
                        value: state.data!.tipoMovimentacao,
                        items: [
                          CampoSelectItem<String>(
                            label: 'Entrada',
                            value: 'entrada',
                          ),
                          CampoSelectItem<String>(
                            label: 'Saída',
                            value: 'saida',
                          ),
                        ],
                        onChange: (value) {
                          state.data!.tipoMovimentacao = value;
                          setState(() {
                            state.data!.dataPagamento = null;
                            state.data!.dataVencimento = null;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextfieldComponent(
                        label: 'Descrição',
                        text: state.data!.descricao,
                        onChange: (value) {
                          state.data!.descricao = value;
                        },
                      ),
                      TextfieldComponent(
                        label: (state.data!.tipoMovimentacao == 'entrada')
                            ? 'Data do Pagamento'
                            : 'Data de Vencimento',
                        text:
                            (state.data!.dataPagamento != null ||
                                state.data!.dataVencimento != null)
                            ? Util.dateFormatString(
                                ((state.data!.tipoMovimentacao == 'entrada')
                                    ? state.data!.dataPagamento!
                                    : state.data!.dataVencimento!),
                              )
                            : '',
                        readOnly: true,
                        onClick: () async {
                          DateTime? data = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          );
                          if (data != null) {
                            if (state.data!.tipoMovimentacao == 'entrada') {
                              state.data!.dataPagamento = data.toString();
                            } else {
                              state.data!.dataVencimento = data.toString();
                            }
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      CampoSelectComponent<String>(
                        label: 'Forma de Pagamento',
                        value: state.data!.formaPagamento,
                        items: [
                          CampoSelectItem<String>(
                            label: 'Dinheiro',
                            value: 'dinheiro',
                          ),
                          CampoSelectItem<String>(
                            label: 'Cartão de Crédito',
                            value: 'cartao_credito',
                          ),
                          CampoSelectItem<String>(
                            label: 'Cartão de Débito',
                            value: 'cartao_debito',
                          ),
                          CampoSelectItem<String>(
                            label: 'Boleto',
                            value: 'boleto',
                          ),
                          CampoSelectItem<String>(label: 'Pix', value: 'pix'),
                          CampoSelectItem<String>(
                            label: 'Pix Particular',
                            value: 'pix_particular',
                          ),
                        ],
                        onChange: (value) {
                          state.data!.formaPagamento = value;
                        },
                      ),
                      TextfieldComponent(
                        label: 'Valor',
                        text: Util.stringFormatValor(state.data!.valor ?? 0),
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MoneyInputFormatter(
                            locale: (Preferences.instance.moeda == 'R\$'
                                ? 'pt_BR'
                                : (Preferences.instance.moeda == '\$'
                                      ? 'en_US'
                                      : 'de_DE')),
                            symbol: Preferences.instance.moeda,
                          ),
                        ],
                        onChange: (value) {
                          String valor = value
                              .replaceAll(Preferences.instance.moeda, '')
                              .replaceAll('.', '')
                              .replaceAll(',', '.');
                          state.data!.valor = double.parse(valor);
                        },
                      ),
                      SizedBox(height: 10),
                      TextfieldComponent(
                        label: 'Observação',
                        text: state.data!.observacao,
                        onChange: (value) {
                          state.data!.observacao = value;
                        },
                      ),
                    ],
                  ),
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
    );
  }

  Future<void> _deleteFluxoCaixa(BuildContext contextScreen) {
    return showDialog<void>(
      context: contextScreen,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Fluxo de Caixa'),
          content: const Text('Tem certeza que deseja excluir?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                Navigator.of(context).pop();
                bool result = await contextScreen
                    .read<FluxoCaixaItemController>()
                    .delete();
                if (result) {
                  appRouter.pushReplacement('/fluxocaixa');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
