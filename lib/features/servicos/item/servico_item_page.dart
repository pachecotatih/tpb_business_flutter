import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/formatters/money_input_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/servicos/item/servico_item_controller.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class ServicoItemPage extends StatefulWidget {
  final String uid;
  final bool isAgendamento;
  const ServicoItemPage({super.key, this.uid = '', this.isAgendamento = false});

  @override
  State<ServicoItemPage> createState() => _ServicoItemPageState();
}

class _ServicoItemPageState extends State<ServicoItemPage> {
  @override
  void initState() {
    super.initState();
    if (widget.uid.isNotEmpty) {
      context.read<ServicoItemController>().get(widget.uid);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicoItemController, StateBloc<ServicoModel>>(
      builder: (context, state) => ThemePage(
        title: widget.uid.isNotEmpty ? 'Editar Serviço' : 'Novo Serviço',
        floatingActionButton: FloatingActionButton(
          backgroundColor: Cores.positiveColor,
          foregroundColor: Colors.white,
          tooltip: "Salvar",
          child: const Icon(Icons.check),
          onPressed: () async {
            bool result = await context.read<ServicoItemController>().save();
            if (result) {
              if (widget.isAgendamento && context.mounted) {
                appRouter.pop(
                  context.read<ServicoItemController>().state.data!,
                );
              } else {
                appRouter.pushReplacement('/servico');
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
                _deleteServico(context);
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
                      label: 'Valor do Serviço (${Preferences.instance.moeda})',
                      text: Util.stringFormatValor(
                        state.data!.valorPadrao ?? 0,
                      ),
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MoneyInputFormatter(
                          locale: (Preferences.instance.moeda == 'R\$'
                              ? 'pt_BR'
                              : (Preferences.instance.moeda == '\$'
                                    ? 'en_US'
                                    : 'de_DE')),
                          symbol: Preferences.instance.moeda,
                        ),
                      ],
                      keyboardType: TextInputType.number,
                      onChange: (value) {
                        String valor = value
                            .replaceAll(Preferences.instance.moeda, '')
                            .replaceAll('.', '')
                            .replaceAll(',', '.');
                        state.data!.valorPadrao = double.parse(valor);
                      },
                    ),
                    TextfieldComponent(
                      label: 'Duração do Serviço',
                      text: (state.data!.duracaoPadrao ?? '00:00').toString(),
                      readOnly: true,
                      onClick: () async => await _selectTime(context),
                      onChange: (value) => null,
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

  Future<void> _selectTime(BuildContext context) async {
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

      context.read<ServicoItemController>().state.data!.duracaoPadrao =
          '$hora24h:$minuto24h';
      setState(() {});
    }
  }

  Future<void> _deleteServico(BuildContext contextScreen) async {
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
                bool result = await contextScreen
                    .read<ServicoItemController>()
                    .delete();
                if (result) {
                  appRouter.pushReplacement('/servico');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
