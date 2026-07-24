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
  ClienteModel cliente = ClienteModel();
  @override
  void initState() {
    super.initState();
    cliente = widget.state.data!.cliente ?? ClienteModel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: CampoSelectPesquisaComponent<ClienteModel>(
                items: (widget.state.data!.loadingClientes)
                    ? [
                        CampoSelectItem<ClienteModel>(
                          label: cliente.nome,
                          value: cliente,
                        ),
                      ]
                    : [
                        ...(widget.state.data!.clientes ?? []).map(
                          (e) => CampoSelectItem<ClienteModel>(
                            label: e.nome,
                            value: e,
                          ),
                        ),
                      ],
                label: 'Cliente',
                value: widget.state.data!.cliente ?? ClienteModel(),
                onChange: (ClienteModel value) async {
                  widget.state.data!.cliente = value;
                  widget.state.data!.clienteId = value.id;

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
                ClienteModel? cliente = await context.push<ClienteModel>(
                  '/cliente/new',
                  extra: true,
                );
                if (cliente != null) {
                  widget.state.data!.clientes?.add(cliente);
                  widget.state.data!.cliente = cliente;
                  widget.state.data!.clienteId = cliente.id;
                }
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        if ((widget.state.data!.clienteId ?? 0) > 0) ...[
          SizedBox(height: 20),
          Text(
            'Nome: ${widget.state.data!.cliente?.nome}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Telefone: ${widget.state.data!.cliente?.telefone ?? '-'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Email: ${widget.state.data!.cliente?.email ?? '-'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
