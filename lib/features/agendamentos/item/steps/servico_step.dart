import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/formatters/money_input_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class ServicoStep extends StatefulWidget {
  final StateBloc<AgendamentoModel> state;
  const ServicoStep({super.key, required this.state});

  @override
  State<ServicoStep> createState() => _ServicoStepState();
}

class _ServicoStepState extends State<ServicoStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CampoSelectPesquisaComponent<ServicoModel>(
                items: widget.state.data!.loadingServicos
                    ? [
                        CampoSelectItem<ServicoModel>(
                          label: 'Carregando...',
                          value: ServicoModel(),
                        ),
                      ]
                    : [
                        ...(widget.state.data!.servicosInit ?? []).map(
                          (e) => CampoSelectItem<ServicoModel>(
                            label:
                                '${e.nome} - ${Util.stringFormatValor(e.valorPadrao ?? 0)}',
                            value: e,
                          ),
                        ),
                      ],
                label: 'Serviço',
                value: ServicoModel(),
                onChange: (value) async {
                  widget.state.data!.servicos ??= [];
                  widget.state.data!.servicos!.add(value);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Cores.positiveColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                ServicoModel? servicoApi = await context.push<ServicoModel>(
                  '/servico/new',
                  extra: true,
                );
                if (servicoApi != null) {
                  widget.state.data!.servicosInit ??= [];
                  widget.state.data!.servicosInit?.add(servicoApi);
                  widget.state.data!.servicos ??= [];
                  widget.state.data!.servicos?.add(servicoApi);
                }
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),

        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.state.data!.servicos?.length ?? 0,
          itemBuilder: (context, index) {
            ServicoModel? servico = widget.state.data!.servicos?[index];
            return _itemServico(servico ?? ServicoModel());
          },
        ),
      ],
    );
  }

  Widget _itemServico(ServicoModel servico) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      servico.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remover serviço',
                style: IconButton.styleFrom(
                  backgroundColor: Cores.negativeColor.withValues(alpha: 0.1),
                  foregroundColor: Cores.negativeColor,
                ),
                onPressed: () async {
                  // implementar ação de deletar o serviço do relacionamento com o agendamento quando for editar
                  setState(() {
                    widget.state.data!.servicos?.remove(servico);
                  });
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextfieldComponent(
                  label: 'Valor (${Preferences.instance.moeda})',
                  text: Util.stringFormatValor(servico.valorPadrao ?? 0),
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MoneyInputFormatter(
                      locale: Preferences.instance.moeda == 'R\$'
                          ? 'pt_BR'
                          : (Preferences.instance.moeda == '\$'
                                ? 'en_US'
                                : 'de_DE'),
                      symbol: Preferences.instance.moeda,
                    ),
                  ],
                  onChange: (value) {
                    String valor = value
                        .replaceAll(Preferences.instance.moeda, '')
                        .replaceAll('.', '')
                        .replaceAll(',', '.');

                    servico.valorPadrao = double.tryParse(valor) ?? 0;
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextfieldComponent(
                  label: 'Duração',
                  text: servico.duracaoPadrao ?? '00:00',
                  readOnly: true,
                  onClick: () => _selectTime(context, servico),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, ServicoModel? servico) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null &&
        context.mounted &&
        picked.format(context) != '00:00') {
      final String hora24h = picked.hour.toString().padLeft(2, '0');
      final String minuto24h = picked.minute.toString().padLeft(2, '0');

      servico?.duracaoPadrao = '$hora24h:$minuto24h';

      setState(() {});
    }
  }
}
