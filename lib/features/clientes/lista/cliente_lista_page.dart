import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/clientes/lista/cliente_lista_controller.dart';

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
    context.read<ClienteListaController>().close();
  }

  @override
  Widget build(BuildContext context) {
    return ThemePage(
      bottomAppBarItems: [
        BottomButton(
          icon: Icons.add,
          label: 'Novo',
          color: Cores.positiveColor,
          onPressed: () => context.pushReplacement('/cliente/new'),
        ),
      ],
      title: 'Clientes',
      children: [
        Bloco(
          child:
              BlocConsumer<
                ClienteListaController,
                StateBloc<List<ClienteModel>>
              >(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return (state.data ?? []).isEmpty
                      ? const Center(
                          child: TextoPadrao(text: 'Nenhum cliente cadastrado'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final cliente = state.data![index];
                            return ListTile(
                              title: Text(cliente.nome),
                              onTap: () => context.pushReplacement(
                                '/cliente/${cliente.uid}',
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Cores.negativeColor,
                                ),
                                onPressed: () => context
                                    .read<ClienteListaController>()
                                    .delete(cliente.uid),
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
        ),
      ],
    );
  }

  // contextpushReplacement('/cliente/new');
  // contextpushReplacement('/cliente/123');
}
