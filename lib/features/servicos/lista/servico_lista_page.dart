import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/dialog/confirm_dialog.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/servicos/lista/servico_lista_controller.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class ServicoListaPage extends StatefulWidget {
  const ServicoListaPage({super.key});

  @override
  State<ServicoListaPage> createState() => _ServicoListaPageState();
}

class _ServicoListaPageState extends State<ServicoListaPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServicoListaController>().getServicos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ServicoListaController>();
    return ThemePage(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Cores.positiveColor,
        foregroundColor: Colors.white,
        tooltip: "Adicionar serviço",
        child: const Icon(Icons.add),
        onPressed: () => context.pushReplacement('/servico/new'),
      ),
      title: 'Serviços',
      children: [
        Bloco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextfieldComponent(
                label: 'Buscar serviço',
                text: controller.busca.value,
                onChange: (value) {
                  controller.busca.value = value;
                },
              ),
              const SizedBox(height: 10),
              BlocConsumer<
                ServicoListaController,
                StateBloc<List<ServicoModel>>
              >(
                builder: (context, state) {
                  final buscaValue = controller.busca.value.toLowerCase();
                  final servicosFiltrados = (state.data ?? [])
                      .where(
                        (element) =>
                            element.nome.toLowerCase().contains(buscaValue),
                      )
                      .toList();
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return servicosFiltrados.isEmpty
                      ? const Center(
                          child: TextoPadrao(
                            text: 'Nenhum serviço foi cadastrado ainda.',
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: servicosFiltrados.length,
                          itemBuilder: (context, index) {
                            final servico = servicosFiltrados[index];
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
                                title: Text(servico.nome),
                                subtitle: Wrap(
                                  spacing: 5,
                                  children: [
                                    if (servico.valorPadrao != null)
                                      Text(
                                        'Valor: ${Preferences.instance.moeda}${Util.stringFormatValor(servico.valorPadrao ?? 0.0)}',
                                      ),
                                    if (servico.valorPadrao != null &&
                                        servico.duracaoPadrao != null)
                                      const Text(' | '),
                                    if (servico.duracaoPadrao != null)
                                      Text('Duração: ${servico.duracaoPadrao}'),
                                  ],
                                ),
                                onTap: () => context.pushReplacement(
                                  '/servico/${servico.uid}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: servico.ativo,
                                      onChanged: (value) => context
                                          .read<ServicoListaController>()
                                          .updateAtivo(
                                            servico.uid,
                                            value ?? false,
                                          ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Cores.negativeColor,
                                      ),
                                      onPressed: () {
                                        _deleteServico(context, servico.uid);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
                listener:
                    (
                      BuildContext context,
                      StateBloc<List<ServicoModel>> state,
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

  Future<void> _deleteServico(BuildContext contextScreen, String uid) async {
    return ConfirmDialog(
      onConfirm: () async {
        await contextScreen.read<ServicoListaController>().delete(uid);
      },
      title: 'Excluir Serviço',
      textContent: 'Tem certeza que deseja excluir?',
    ).show(contextScreen);
  }
}
