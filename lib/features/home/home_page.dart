import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/dialog/agendamento_dialog.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';
import 'package:tpb_business_flutter/features/home/home_controller.dart';
import 'package:tpb_business_flutter/features/home/home_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataFormatada = DateFormat(
    "EEEE, dd 'de' MMMM 'de' yyyy",
    "pt_BR",
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    context.read<HomeController>().getHome();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeController, StateBloc<HomeModel>>(
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
      builder: (context, state) {
        return ThemePage(
          children: (state.isLoading)
              ? [Center(child: CircularProgressIndicator())]
              : [
                  Bloco(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bem vindo, ${Preferences.instance.name}!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TituloH2(
                            text:
                                dataFormatada[0].toUpperCase() +
                                dataFormatada.substring(1),
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Bloco(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: (state.data?.saldoHoje ?? 0) > 0
                                      ? Cores.positiveColor.withValues(
                                          alpha: 0.2,
                                        )
                                      : (state.data?.saldoHoje ?? 0) < 0
                                      ? Cores.negativeColor.withValues(
                                          alpha: 0.2,
                                        )
                                      : Colors.black45,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  (state.data?.saldoHoje ?? 0) > 0
                                      ? Icons.trending_up
                                      : (state.data?.saldoHoje ?? 0) < 0
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                                  color: (state.data?.saldoHoje ?? 0) > 0
                                      ? Cores.positiveColor
                                      : (state.data?.saldoHoje ?? 0) < 0
                                      ? Cores.negativeColor
                                      : Cores.secondaryText,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TituloH3(text: "Saldo do dia"),
                                  TextoPadrao(
                                    fontSize: 16,
                                    text:
                                        Preferences.instance.moeda +
                                        Util.stringFormatValor(
                                          state.data?.saldoHoje ?? 0,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Bloco(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Cores.positiveColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.trending_up,
                                  color: Cores.positiveColor,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TituloH3(text: "Entradas do dia"),
                                  TituloH3(
                                    text:
                                        Preferences.instance.moeda +
                                        Util.stringFormatValor(
                                          state.data?.entradasHoje ?? 0,
                                        ),
                                    color: Cores.positiveColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Bloco(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Cores.negativeColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.trending_down,
                                  color: Cores.negativeColor,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TituloH3(text: "Saídas do dia"),
                                  TituloH3(
                                    text:
                                        Preferences.instance.moeda +
                                        Util.stringFormatValor(
                                          state.data?.saidasHoje ?? 0,
                                        ),
                                    color: Cores.negativeColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Bloco(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Cores.primaryColor,
                                  ),
                                  TituloH2(
                                    text: "Agendamentos de hoje",
                                    color: Cores.primaryColor,
                                  ),
                                ],
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Cores.primaryColor,
                                ),
                                onPressed: () {
                                  context.pushReplacement('/agendamento');
                                },
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    Text("Ver todos"),
                                    Icon(Icons.arrow_forward_ios, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          spacing: 5,
                          children: [
                            if ((state.data!.agendamentosHoje ?? [])
                                .isEmpty) ...[
                              TextoPadrao(text: "Nenhum agendamento para hoje"),
                            ] else
                              ...(state.data!.agendamentosHoje ?? []).map((e) {
                                return ListTile(
                                  title: TituloH3(
                                    text: e.cliente!.nome,
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 5,
                                    children: [
                                      Icon(Icons.access_time),
                                      TextoPadrao(
                                        text:
                                            "${Util.timeFormatString(e.dataInicio!)} - ${Util.timeFormatString(e.dataFim!)}",
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    _showAgendamentoDialog(context, e);
                                  },
                                );
                              }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
        );
      },
    );
  }

  Future<dynamic> _showAgendamentoDialog(
    BuildContext context,
    AgendamentoModel e,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AgendamentoDialog(
          contextScreen: context,
          cliente: e.cliente,
          dataInicio: e.dataInicio ?? '',
          dataFim: e.dataFim ?? '',
          observacao: e.observacao ?? '',
          servicos: e.servicos ?? [],
          valorTotal: e.valorTotal ?? 0.0,
          status: e.status ?? '',
          uid: e.uid ?? '',
          buttons: [],
        );
      },
    );
  }
}
