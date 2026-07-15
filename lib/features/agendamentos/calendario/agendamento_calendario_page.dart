import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/agendamentos/calendario/agendamento_calendario_controller.dart';
import 'package:tpb_business_flutter/features/agendamentos/meetings_model.dart';

class AgendamentoCalendarioPage extends StatefulWidget {
  const AgendamentoCalendarioPage({super.key});

  @override
  State<AgendamentoCalendarioPage> createState() =>
      _AgendamentoCalendarioPageState();
}

class _AgendamentoCalendarioPageState extends State<AgendamentoCalendarioPage> {
  @override
  void initState() {
    super.initState();
    context.read<AgendamentoCalendarioController>().getAgendamentos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      AgendamentoCalendarioController,
      StateBloc<MeetingDataSource>
    >(
      builder: (BuildContext context, StateBloc<MeetingDataSource> state) {
        return ThemePage(
          physics: NeverScrollableScrollPhysics(),
          title: 'Agendamentos',
          floatingActionButton: FloatingActionButton(
            backgroundColor: Cores.positiveColor,
            foregroundColor: Colors.white,
            tooltip: "Adicionar agendamento",
            child: const Icon(Icons.add),
            onPressed: () {
              context.pushReplacement(
                '/agendamento/new',
                extra: {'data': DateTime.now()},
              );
            },
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Bloco(
                child: (state.isLoading)
                    ? const Center(child: CircularProgressIndicator())
                    : SfCalendar(
                        onTap: (CalendarTapDetails details) {
                          if (details.targetElement !=
                              CalendarElement.appointment) {
                            return;
                          }

                          final meeting =
                              details.appointments!.first as Meeting;
                          final BuildContext contextScreen = context;
                          showDialog<void>(
                            context: contextScreen,
                            barrierColor: Colors.black54,
                            builder: (BuildContext context) {
                              return Dialog(
                                constraints: BoxConstraints(maxWidth: 400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Header colorido
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Cores.primaryColor,
                                            Cores.primaryColor.withValues(
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
                                              const SizedBox(width: 8),
                                              Text(
                                                'Agendamento',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 13,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            meeting.cliente?.nome ?? 'Sem nome',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Conteúdo
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Serviços
                                          if (meeting.servicos.isNotEmpty) ...[
                                            Text(
                                              'Serviços',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Cores.secondaryText,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: meeting.servicos
                                                  .map(
                                                    (s) => Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Cores
                                                            .primaryColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        border: Border.all(
                                                          color: Cores
                                                              .primaryColor
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        s.nome,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Cores
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          // Valor Total
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Cores.principalBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.attach_money_rounded,
                                                  color: Cores.positiveColor,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Valor total',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Cores.secondaryText,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${Preferences.instance.moeda} ${Util.stringFormatValor(meeting.valorTotal)}',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Cores.positiveColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Observação
                                          if (meeting
                                              .observacao
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 14),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.notes_rounded,
                                                  size: 16,
                                                  color: Cores.secondaryText,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    meeting.observacao,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Cores.secondaryText,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],

                                          const SizedBox(height: 20),

                                          // Botões
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    side: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      context.pop(),
                                                  child: Text(
                                                    'Fechar',
                                                    style: TextStyle(
                                                      color:
                                                          Cores.secondaryText,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Cores.primaryColor,
                                                        Cores.primaryColor
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Cores
                                                            .primaryColor
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (meeting.status ==
                                                          'concluido') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) => AlertDialog(
                                                            title: Text('Ops!'),
                                                            content: Text(
                                                              'Você não pode mais editar este agendamento, pois já foi concluído.',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                                child: Text(
                                                                  'Entendi',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        context.pop();
                                                        contextScreen
                                                            .pushReplacement(
                                                              '/agendamento/${meeting.uid}',
                                                            );
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'Editar',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        monthViewSettings: MonthViewSettings(showAgenda: true),
                        view: CalendarView.day,
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          timelineAppointmentHeight: 500,
                        ),
                        showNavigationArrow: true,
                        allowedViews: [
                          CalendarView.day,
                          CalendarView.week,
                          CalendarView.month,
                        ],
                        dataSource: state.data,
                        appointmentBuilder: (context, calendarAppointmentDetails) {
                          final Meeting meeting =
                              calendarAppointmentDetails.appointments.first
                                  as Meeting;
                          return Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: meeting.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: meeting.status == 'concluido',
                                  side: const BorderSide(color: Colors.white),
                                  onChanged: (bool? value) {
                                    if ((value ?? false)) {
                                      BuildContext contextScreen = context;
                                      showDialog<void>(
                                        context: contextScreen,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Adicionar pagamento',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CampoSelectComponent<String>(
                                                  items: [
                                                    CampoSelectItem<String>(
                                                      label: 'Dinheiro',
                                                      value: 'dinheiro',
                                                    ),
                                                    CampoSelectItem<String>(
                                                      label:
                                                          'Cartão de Crédito',
                                                      value: 'cartao_credito',
                                                    ),
                                                    CampoSelectItem<String>(
                                                      label:
                                                          'Cartão de Débito',
                                                      value: 'cartao_debito',
                                                    ),
                                                    CampoSelectItem<String>(
                                                      label: 'Boleto',
                                                      value: 'boleto',
                                                    ),
                                                    CampoSelectItem<String>(
                                                      label: 'Pix',
                                                      value: 'pix',
                                                    ),
                                                    CampoSelectItem<String>(
                                                      label: 'Pix Particular',
                                                      value: 'pix_particular',
                                                    ),
                                                  ],
                                                  label: "Forma de pagamento",
                                                  value: meeting.formaPagamento,
                                                  onChange: (value) {
                                                    meeting.formaPagamento =
                                                        value;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Confirmar'),
                                                onPressed: () async {
                                                  meeting.status = value!
                                                      ? 'concluido'
                                                      : 'agendado';
                                                  Navigator.of(context).pop();
                                                  bool
                                                  result = await contextScreen
                                                      .read<
                                                        AgendamentoCalendarioController
                                                      >()
                                                      .updateAgendamentos(
                                                        meeting,
                                                      );
                                                  if (result &&
                                                      contextScreen.mounted) {
                                                    ScaffoldMessenger.of(
                                                      contextScreen,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Agendamento atualizado com sucesso',
                                                        ),
                                                        backgroundColor:
                                                            Cores.positiveColor,
                                                      ),
                                                    );

                                                    setState(() {});
                                                  } else {
                                                    meeting.status = 'agendado';
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),

                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meeting.eventName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (meeting.cliente!.telefone != null)
                                        Text(
                                          meeting.cliente!.telefone!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
      listener: (BuildContext context, StateBloc<MeetingDataSource> state) {
        if (state.hasError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.hasError.toString()),
              backgroundColor: Cores.negativeColor,
            ),
          );
        }
      },
    );
  }
}
