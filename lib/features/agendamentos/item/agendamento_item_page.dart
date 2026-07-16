import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/dialog/confirm_dialog.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/agendamento_item_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/item/steps/agendamento_step.dart';
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
  final ScrollController _stepScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context.read<AgendamentoItemController>().get(widget.uid);
  }

  @override
  void dispose() {
    _stepScrollController.dispose();
    super.dispose();
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
                  setState(() {
                    state.data!.step = state.data!.step - 1;
                    _changeStep(state.data!.step, context);
                  });
                },
              ),
            if ((state.data!.uid ?? '').isNotEmpty) ...[
              BottomButton(
                label: 'Excluir',
                icon: Icons.delete,
                color: Cores.negativeColor,
                onPressed: () {
                  _deleteAgendamento(context);
                },
              ),
            ],
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!_validarCamposStep(state.data!.step, context)) return;
              if (state.data!.step < 2) {
                setState(() {
                  state.data!.step = state.data!.step + 1;
                  _changeStep(state.data!.step, context);
                });
              } else {
                bool result = await context
                    .read<AgendamentoItemController>()
                    .save();
                if (result) {
                  appRouter.pushReplacement('/agendamento');
                }
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
        final servicos =
            context.read<AgendamentoItemController>().state.data!.servicos ??
            [];
        if (servicos.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecione um ou mais serviços'),
              backgroundColor: Cores.negativeColor,
            ),
          );
          return false;
        }

        bool servicoInvalido = servicos.any(
          (servico) =>
              (servico.valorPadrao == null || servico.valorPadrao == 0) ||
              (servico.duracaoPadrao == null ||
                  servico.duracaoPadrao!.trim().isEmpty ||
                  servico.duracaoPadrao == '00:00'),
        );
        if (servicoInvalido) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('O serviço precisa conter um valor e uma duração.'),
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
    return [_stepHeader(2), AgendamentoStep(state: state, date: widget.date)];
  }

  Widget _stepHeader(int step) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        controller: _stepScrollController,
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepItem('Cliente', step, 0),
              _stepDivider(step >= 1),
              _stepItem('Serviços', step, 1),
              _stepDivider(step >= 2),
              _stepItem('Agendamento', step, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String text, int stepAtual, int step) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            (stepAtual > step) ? Icons.check_circle : Icons.circle,
            size: 16,
            color: (stepAtual >= step)
                ? Cores.primaryColor
                : Colors.grey.shade300,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (stepAtual >= step) ? Cores.primaryColor : Colors.grey,
              fontWeight: (stepAtual >= step)
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDivider(bool completed) {
    return Expanded(
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

  void _scrollToStep(int step, BuildContext context) {
    if (!_stepScrollController.hasClients) return;
    double itemWidth =
        MediaQuery.of(context).size.width * 0.8; // ajuste conforme seu layout

    _stepScrollController.animateTo(
      step * itemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _changeStep(int step, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStep(step, context);
    });
  }

  Future<void> _deleteAgendamento(BuildContext contextScreen) {
    return ConfirmDialog(
      onConfirm: () async {
        bool result = await contextScreen
            .read<AgendamentoItemController>()
            .delete();
        if (result) {
          appRouter.pushReplacement('/agendamento');
        }
      },
      title: 'Excluir Agendamento',
      textContent: 'Tem certeza que deseja excluir?',
    ).show(contextScreen);
  }
}
