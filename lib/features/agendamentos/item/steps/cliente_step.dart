import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';

class ClienteStep extends StatefulWidget {
  final StateBloc<AgendamentoModel> state;
  const ClienteStep({super.key, required this.state});

  @override
  State<ClienteStep> createState() => _ClienteStepState();
}

class _ClienteStepState extends State<ClienteStep> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: CampoSelectPesquisaComponent<int>(
            items: [
              ...(widget.state.data!.clientes ?? []).map(
                (e) => CampoSelectItem<int>(label: e.nome, value: e.id ?? 0),
              ),
            ],
            label: 'Cliente',
            value: widget.state.data!.clienteId ?? 0,
            onChange: (value) async {
              widget.state.data!.clienteId = value;
            },
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Cores.positiveColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            ClienteModel? cliente = await context.push<ClienteModel>(
              '/cliente/new',
              extra: true,
            );
            if (cliente != null) {
              widget.state.data!.clientes?.add(cliente);
              widget.state.data!.clienteId = cliente.id;
            }
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
