import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
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
                    child: Column(
                      children: [
                        TituloH1(
                          text: "Bem vindo, ${Preferences.instance.name}!",
                        ),
                        TituloH2(
                          text:
                              dataFormatada[0].toUpperCase() +
                              dataFormatada.substring(1),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Bloco(
                          child: Column(
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
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Bloco(
                          child: Column(
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
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Bloco(
                          child: Column(
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
                              TituloH2(
                                text: "Agendamentos de hoje",
                                color: Cores.primaryColor,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Cores.primaryColor,
                                ),
                                onPressed: () {
                                  context.pushReplacement('/agendamentos');
                                },
                                child: Text("Ver todos"),
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
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          constraints: BoxConstraints(
                                            maxWidth: 400,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Header colorido
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 18,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Cores.primaryColor,
                                                      Cores.primaryColor
                                                          .withValues(
                                                            alpha: 0.75,
                                                          ),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.person_rounded,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Agendamento',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.85,
                                                                ),
                                                            fontSize: 13,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      e.cliente!.nome,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (e
                                                        .servicos!
                                                        .isNotEmpty) ...[
                                                      Text(
                                                        'Serviços',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Cores
                                                              .secondaryText,
                                                          letterSpacing: 0.8,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 6,
                                                        children: e.servicos!
                                                            .map(
                                                              (s) => Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Cores
                                                                      .primaryColor
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Cores
                                                                        .primaryColor
                                                                        .withValues(
                                                                          alpha:
                                                                              0.3,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  s.nome,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Cores
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                      ),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                    ],
                                                    // Data início e fim
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Cores
                                                            .principalBackground,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 18,
                                                            color: Cores
                                                                .primaryColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            '${Util.dateFormatString(e.dataInicio.toString())} ${Util.timeFormatString(e.dataInicio.toString())} - ${Util.timeFormatString(e.dataFim.toString())}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Cores
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Valor Total
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Cores
                                                            .principalBackground,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .attach_money_rounded,
                                                            color: Cores
                                                                .positiveColor,
                                                            size: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Valor total',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Cores
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${Preferences.instance.moeda} ${Util.stringFormatValor(e.valorTotal ?? 0)}',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Cores
                                                                      .positiveColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Observação
                                                    if ((e.observacao ?? '')
                                                        .isNotEmpty) ...[
                                                      const SizedBox(
                                                        height: 14,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.notes_rounded,
                                                            size: 16,
                                                            color: Cores
                                                                .secondaryText,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              e.observacao!,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Cores
                                                                    .secondaryText,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
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
}
