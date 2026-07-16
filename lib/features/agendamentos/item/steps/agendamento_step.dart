import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';

class AgendamentoStep extends StatefulWidget {
  final StateBloc<AgendamentoModel> state;
  final DateTime date;
  const AgendamentoStep({super.key, required this.state, required this.date});

  @override
  State<AgendamentoStep> createState() => _AgendamentoStepState();
}

class _AgendamentoStepState extends State<AgendamentoStep> {
  late ClienteModel selectedCliente;
  late double total;
  Duration totalDuration = Duration.zero;

  DateTime? _getCalculatedDataFim() {
    if (widget.state.data!.dataInicio == null) return null;
    try {
      final inicio = DateTime.parse(widget.state.data!.dataInicio!);

      totalDuration = Duration.zero;
      for (var servico in (widget.state.data!.servicos ?? [])) {
        final duracao = servico.duracaoPadrao;
        if (duracao != null && duracao.isNotEmpty && duracao.contains(':')) {
          final parts = duracao.split(':');
          if (parts.length >= 2) {
            final hours = int.tryParse(parts[0]) ?? 0;
            final minutes = int.tryParse(parts[1]) ?? 0;
            totalDuration += Duration(hours: hours, minutes: minutes);
          }
        }
      }

      return inicio.add(totalDuration);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.state.data!.dataInicio ??= widget.date.toString();
    widget.state.data!.dataFim =
        _getCalculatedDataFim()?.toString() ?? widget.date.toString();
    selectedCliente = (widget.state.data!.clientes ?? []).firstWhere(
      (c) => c.id == widget.state.data!.clienteId,
      orElse: () => ClienteModel(nome: 'Não selecionado'),
    );

    total = (widget.state.data!.servicos ?? []).fold(
      0.0,
      (sum, item) => sum + (item.valorPadrao ?? 0.0),
    );
    widget.state.data!.valorTotal = total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.state.data!.servicos != null &&
            widget.state.data!.servicos!.isNotEmpty) ...[
          Text(
            'Serviços Selecionados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Cores.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Cores.principalBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: widget.state.data!.servicos!.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final servico = entry.value;
                final isLast = index == widget.state.data!.servicos!.length - 1;
                final valorStr =
                    '${Preferences.instance.moeda} ${Util.stringFormatValor(servico.valorPadrao ?? 0.0)}';
                final duracaoStr = servico.duracaoPadrao ?? '00:00';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              servico.nome,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Cores.principalText,
                              ),
                            ),
                          ),
                          Text(
                            '$valorStr | $duracaoStr',
                            style: TextStyle(
                              fontSize: 14,
                              color: Cores.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (!isLast) const Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'Cliente: ${selectedCliente.nome}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextfieldComponent(
          label: 'Data Início',
          text: () {
            if (widget.state.data!.dataInicio == null) return '';
            final parsed = DateTime.tryParse(widget.state.data!.dataInicio!);
            if (parsed == null) return '';
            return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
          }(),
          readOnly: true,
          onClick: () async {
            DateTime? data = await showDatePicker(
              context: context,
              initialDate: widget.state.data!.dataInicio != null
                  ? DateTime.parse(widget.state.data!.dataInicio!)
                  : widget.date,
              firstDate: DateTime(2000),
              lastDate: DateTime(3000),
            );
            if (data != null && context.mounted) {
              final prevTime = widget.state.data!.dataInicio != null
                  ? TimeOfDay.fromDateTime(
                      DateTime.parse(widget.state.data!.dataInicio!),
                    )
                  : const TimeOfDay(hour: 0, minute: 0);
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: prevTime,
              );
              final selectedTime = time ?? prevTime;
              DateTime dataHora = DateTime(
                data.year,
                data.month,
                data.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              setState(() {
                widget.state.data!.dataInicio = dataHora.toString();
                widget.state.data!.dataFim = _getCalculatedDataFim()
                    ?.toString();
              });
            }
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Finalização esperada: ${() {
            if (widget.state.data!.dataFim == null) return '';
            final parsed = DateTime.tryParse(widget.state.data!.dataFim!);
            if (parsed == null) return '';
            return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
          }()}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "Duração total do serviço: ${totalDuration.inHours.toString().padLeft(2, '0')}:${totalDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Text(
          'Total: ${Preferences.instance.moeda}${Util.stringFormatValor(total)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
