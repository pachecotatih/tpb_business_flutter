import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
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
    return ThemePage(
      bottomAppBarItems: [
        BottomButton(
          icon: Icons.add,
          label: 'Novo',
          color: Cores.positiveColor,
          onPressed: () => context.pushReplacement('/servico/new'),
        ),
      ],
      title: 'Serviços',
      children: [
        Bloco(
          child:
              BlocConsumer<
                ServicoListaController,
                StateBloc<List<ServicoModel>>
              >(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return (state.data ?? []).isEmpty
                      ? const Center(
                          child: TextoPadrao(
                            text: 'Nenhum serviço foi cadastrado ainda.',
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final servico = state.data![index];
                            return ListTile(
                              title: Text(
                                '${servico.nome} - ${Preferences.instance.moeda}${Util.stringFormatValor(servico.valorPadrao ?? 0.0)}',
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
        ),
      ],
    );
  }

  Future<void> _deleteServico(BuildContext contextScreen, String uid) async {
    return showDialog<void>(
      context: contextScreen,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Serviço'),
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
                await contextScreen.read<ServicoListaController>().delete(uid);
              },
            ),
          ],
        );
      },
    );
  }
}
