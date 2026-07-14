import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/campoSelect_component.dart';
import 'package:tpb_business_flutter/core/components/formatters/brazil_phone_formatter.dart';
import 'package:tpb_business_flutter/core/components/formatters/uppercase_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/clientes/item/cliente_item_controller.dart';

class ClienteItemPage extends StatefulWidget {
  final String uid;
  final bool isAgendamento;
  const ClienteItemPage({super.key, this.uid = '', this.isAgendamento = false});

  @override
  State<ClienteItemPage> createState() => _ClienteItemPageState();
}

class _ClienteItemPageState extends State<ClienteItemPage> {
  @override
  void initState() {
    super.initState();
    if (widget.uid.isNotEmpty) {
      context.read<ClienteItemController>().get(widget.uid);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClienteItemController, StateBloc<ClienteModel>>(
      builder: (context, state) => ThemePage(
        title: widget.uid.isNotEmpty ? 'Editar Cliente' : 'Novo Cliente',
        floatingActionButton: FloatingActionButton(
          backgroundColor: Cores.positiveColor,
          foregroundColor: Colors.white,
          tooltip: "Salvar",
          child: const Icon(Icons.check),
          onPressed: () async {
            bool result = await context.read<ClienteItemController>().save();
            if (result) {
              if (widget.isAgendamento && context.mounted) {
                appRouter.pop(
                  context.read<ClienteItemController>().state.data!,
                );
              } else {
                appRouter.pushReplacement('/cliente');
              }
            }
          },
        ),
        bottomAppBarItems: [
          if (state.data!.uid.isNotEmpty)
            BottomButton(
              icon: Icons.delete,
              label: 'Excluir',
              color: Cores.negativeColor,
              onPressed: () async {
                _deleteCliente(context, state.data!.uid);
              },
            ),
        ],
        children: [
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
          if (!state.isLoading) ...[
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextfieldComponent(
                      label: 'Nome',
                      text: state.data!.nome,
                      onChange: (value) => state.data!.nome = value,
                    ),
                    TextfieldComponent(
                      label: 'Email',
                      text: state.data!.email,
                      onChange: (value) => state.data!.email = value,
                    ),
                    TextfieldComponent(
                      label: 'Telefone',
                      text: state.data!.telefone,
                      keyboardType: TextInputType.phone,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        BrazilPhoneFormatter(),
                      ],
                      onChange: (value) => state.data!.telefone = value,
                    ),
                    CampoSelectComponent<String>(
                      label: 'Tipo de cliente',
                      items: [
                        CampoSelectItem<String>(
                          value: 'PF',
                          label: 'Pessoa Física',
                        ),
                        CampoSelectItem<String>(
                          value: 'PJ',
                          label: 'Pessoa Jurídica',
                        ),
                      ],
                      value: state.data?.tipo ?? 'PF',
                      onChange: (value) {
                        state.data!.tipo = value;
                        setState(() {
                          state.data!.documento = '';
                        });
                      },
                    ),
                    TextfieldComponent(
                      label: (state.data!.tipo == 'PF') ? 'CPF' : 'CNPJ',
                      text: state.data!.documento,
                      keyboardType: (state.data!.tipo == 'PF')
                          ? TextInputType.number
                          : TextInputType.text,
                      formatters: [
                        UpperCaseFormatter(),
                        MaskTextInputFormatter(
                          mask: (state.data!.tipo == 'PF')
                              ? '###.###.###-##'
                              : 'AA.AAA.AAA/AAAA-##',
                        ),
                      ],
                      onChange: (value) =>
                          state.data!.documento = value.toUpperCase(),
                    ),
                    TextfieldComponent(
                      label: 'Data de nascimento',
                      text: state.data!.dataNascimento,
                      keyboardType: TextInputType.datetime,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MaskTextInputFormatter(mask: '##/##/####'),
                      ],
                      onChange: (value) => state.data!.dataNascimento = value,
                    ),
                    TextfieldComponent(
                      label: 'Observação',
                      enabledLines: true,
                      keyboardType: TextInputType.multiline,
                      text: state.data!.observacao,
                      onChange: (value) => state.data!.observacao = value,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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

  Future<void> _deleteCliente(BuildContext contextScreen, String uid) {
    return showDialog<void>(
      context: contextScreen,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Cliente'),
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
                    .read<ClienteItemController>()
                    .delete();
                if (result) {
                  appRouter.pushReplacement('/cliente');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
