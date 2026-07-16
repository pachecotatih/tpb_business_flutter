import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/dialog/confirm_dialog.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_controller.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';

class ClienteListaPage extends StatefulWidget {
  const ClienteListaPage({super.key});

  @override
  State<ClienteListaPage> createState() => _ClienteListaPageState();
}

class _ClienteListaPageState extends State<ClienteListaPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClienteListaController>().getClientes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ClienteListaController>();
    return ThemePage(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Cores.positiveColor,
        foregroundColor: Colors.white,
        tooltip: "Adicionar cliente",
        child: const Icon(Icons.add),
        onPressed: () => context.pushReplacement('/cliente/new'),
      ),
      title: 'Clientes',
      children: [
        Bloco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextfieldComponent(
                label: 'Buscar cliente',
                text: controller.busca.value,
                onChange: (value) {
                  controller.busca.value = value;
                },
              ),
              const SizedBox(height: 10),
              BlocConsumer<
                ClienteListaController,
                StateBloc<List<ClienteModel>>
              >(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final buscaValue = controller.busca.value.toLowerCase();
                  final filteredClientes = (state.data ?? []).where((cliente) {
                    return cliente.nome.toLowerCase().contains(buscaValue);
                  }).toList();

                  return filteredClientes.isEmpty
                      ? const Center(
                          child: TextoPadrao(text: 'Nenhum cliente cadastrado'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredClientes.length,
                          itemBuilder: (context, index) {
                            final cliente = filteredClientes[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Cores.principalBackground.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ListTile(
                                hoverColor: Cores.principalBackground
                                    .withValues(alpha: 0.5),
                                title: Text(cliente.nome),
                                onTap: () => context.pushReplacement(
                                  '/cliente/${cliente.uid}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Cores.negativeColor,
                                  ),
                                  onPressed: () {
                                    _deleteCliente(context, cliente.uid);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                },
                listener:
                    (
                      BuildContext context,
                      StateBloc<List<ClienteModel>> state,
                    ) {
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
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCliente(BuildContext contextScreen, String uid) {
    return ConfirmDialog(
      onConfirm: () async {
        await contextScreen.read<ClienteListaController>().delete(uid);
      },
      title: 'Excluir Cliente',
      textContent: 'Tem certeza que deseja excluir?',
    ).show(contextScreen);
  }
}
