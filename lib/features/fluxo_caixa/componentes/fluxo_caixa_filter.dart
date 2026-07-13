import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/components/campoSelect_component.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';

class FluxoCaixaFilter extends StatefulWidget {
  final String tipoMovimentacao;
  final String formaPagamento;
  final String dataInicio;
  final String dataFim;

  final Function(String) onTipoChanged;
  final Function(String) onFormaPagamentoChanged;
  final Function(DateTime) onDataInicioChanged;
  final Function(DateTime) onDataFimChanged;

  final Function() onFilter;
  const FluxoCaixaFilter({
    super.key,
    required this.tipoMovimentacao,
    required this.formaPagamento,
    required this.dataInicio,
    required this.dataFim,
    required this.onTipoChanged,
    required this.onFormaPagamentoChanged,
    required this.onDataInicioChanged,
    required this.onDataFimChanged,
    required this.onFilter,
  });

  @override
  State<FluxoCaixaFilter> createState() => _FluxoCaixaFilterState();
}

class _FluxoCaixaFilterState extends State<FluxoCaixaFilter> {
  late String tipoMovimentacao;
  late String formaPagamento;
  late String dataInicio;
  late String dataFim;

  @override
  void initState() {
    super.initState();
    tipoMovimentacao = widget.tipoMovimentacao;
    formaPagamento = widget.formaPagamento;
    dataInicio = widget.dataInicio;
    dataFim = widget.dataFim;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TituloH1(text: 'Filtros'),
          Spacer(),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Cores.negativeColor),
            child: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CampoSelectComponent<String>(
              label: 'Tipo de movimentação',
              value: tipoMovimentacao,
              items: [
                CampoSelectItem(label: 'Todos', value: 'todos'),
                CampoSelectItem(label: 'Entrada', value: 'entrada'),
                CampoSelectItem(label: 'Saída', value: 'saida'),
              ],
              onChange: (value) {
                setState(() {
                  tipoMovimentacao = value;
                });
              },
            ),
            CampoSelectComponent<String>(
              label: 'Forma de pagamento',
              value: formaPagamento,
              items: [
                CampoSelectItem(label: 'Todas', value: 'todas'),
                CampoSelectItem(label: 'PIX', value: 'pix'),
                CampoSelectItem(label: 'Dinheiro', value: 'dinheiro'),
                CampoSelectItem(label: 'Cartão de Crédito', value: 'credito'),
                CampoSelectItem(label: 'Cartão de Débito', value: 'debito'),
                CampoSelectItem(label: 'Transferência', value: 'transferencia'),
                CampoSelectItem(label: 'Boleto', value: 'boleto'),
              ],
              onChange: (value) {
                setState(() {
                  formaPagamento = value;
                });
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Expanded(
                  child: TextfieldComponent(
                    label: 'Data inicial',
                    readOnly: true,
                    text: Util.dateFormatString(dataInicio),
                    onClick: () async {
                      final value = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(dataInicio),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.parse(dataFim),
                      );

                      if (value != null) {
                        setState(() {
                          dataInicio = value.toIso8601String();
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: TextfieldComponent(
                    label: 'Data final',
                    readOnly: true,
                    text: Util.dateFormatString(dataFim),
                    onClick: () async {
                      final value = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(dataFim),
                        firstDate: DateTime.parse(dataInicio),
                        lastDate: DateTime(3000),
                      );

                      if (value != null) {
                        setState(() {
                          dataFim = value.toIso8601String();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Cores.negativeColor),
          child: const Text('Limpar filtros'),
          onPressed: () {
            widget.onTipoChanged('todos');
            widget.onFormaPagamentoChanged('todas');
            widget.onDataInicioChanged(
              DateTime(DateTime.now().year, DateTime.now().month, 1),
            );
            widget.onDataFimChanged(
              DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
            );
            Navigator.of(context).pop();
            widget.onFilter();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Cores.positiveColor),
          child: const Text('Filtrar'),
          onPressed: () {
            widget.onTipoChanged(tipoMovimentacao);
            widget.onFormaPagamentoChanged(formaPagamento);
            widget.onDataInicioChanged(DateTime.parse(dataInicio));
            widget.onDataFimChanged(DateTime.parse(dataFim));
            Navigator.of(context).pop();
            widget.onFilter();
          },
        ),
      ],
    );
  }
}
