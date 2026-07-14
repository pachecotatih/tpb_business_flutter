import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/agendamento_item_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/steps/cliente_step.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/steps/servico_step.dart';

class AgendamentoItemPage extends StatefulWidget {
  final String uid;
  final DateTime date;
  const AgendamentoItemPage({super.key, required this.uid, required this.date});

  @override
  State<AgendamentoItemPage> createState() => _AgendamentoItemPageState();
}

class _AgendamentoItemPageState extends State<AgendamentoItemPage> {
  @override
  void initState() {
    super.initState();
    context.read<AgendamentoItemController>().get(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgendamentoItemController, StateBloc<AgendamentoModel>>(
      builder: (context, state) {
        return ThemePage(
          bottomAppBarItems: [
            if (state.data!.step > 0)
              BottomButton(
                label: 'Voltar',
                icon: Icons.backspace,
                color: Cores.secondaryText,
                onPressed: () {
                  state.data!.step = state.data!.step - 1;
                  setState(() {});
                },
              ),
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!_validarCamposStep(state.data!.step, context)) return;
              if (state.data!.step < 2) {
                state.data!.step = state.data!.step + 1;
                setState(() {});
              } else {
                context.read<AgendamentoItemController>().save();
              }
            },
            backgroundColor: Cores.positiveColor,
            foregroundColor: Colors.white,
            child: Icon(
              (state.data!.step < 2) ? Icons.arrow_forward : Icons.check,
            ),
          ),
          title: widget.uid == '' ? 'Novo agendamento' : 'Editar agendamento',
          children: [
            Bloco(
              child: (state.isLoading)
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildForm(context, state),
                    ),
            ),
          ],
        );
      },
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

  bool _validarCamposStep(int step, BuildContext context) {
    switch (step) {
      case 0:
        if ((context.read<AgendamentoItemController>().state.data!.clienteId ??
                0) ==
            0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecione um cliente'),
              backgroundColor: Cores.negativeColor,
            ),
          );
          return false;
        }
        break;
      case 1:
        if ((context.read<AgendamentoItemController>().state.data!.servicos ?? []).isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecione um ou mais serviços'),
              backgroundColor: Cores.negativeColor,
            ),
          );
          return false;
        }
        break;
      case 2:
        break;
    }
    return true;
  }

  List<Widget> _buildForm(
    BuildContext context,
    StateBloc<AgendamentoModel> state,
  ) {
    switch (state.data!.step) {
      case 0:
        return _clienteStep(context, state);
      case 1:
        return _servicoStep(context, state);
      case 2:
        return _agendamentoStep(context, state);
      default:
        return [];
    }
  }

  List<Widget> _clienteStep(
    BuildContext context,
    StateBloc<AgendamentoModel> state,
  ) {
    return [_stepHeader(0), ClienteStep(state: state)];
  }

  List<Widget> _servicoStep(
    BuildContext context,
    StateBloc<AgendamentoModel> state,
  ) {
    return [_stepHeader(1), ServicoStep(state: state)];
  }

  List<Widget> _agendamentoStep(
    BuildContext context,
    StateBloc<AgendamentoModel> state,
  ) {
    return [_stepHeader(2)];
  }

  Widget _stepHeader(int step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _stepItem('Cliente', step >= 0),
          _stepDivider(step >= 1),
          _stepItem('Serviços', step >= 1),
          _stepDivider(step >= 2),
          _stepItem('Agendamento', step >= 2),
        ],
      ),
    );
  }

  Widget _stepItem(String text, bool selected) {
    return Expanded(
      flex: 3,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Cores.primaryColor : Colors.grey,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _stepDivider(bool completed) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: completed ? Cores.primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
