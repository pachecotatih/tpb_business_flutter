import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/dialog/agendamento_dialog.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
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
                        allowAppointmentResize: true,
                        onTap: (CalendarTapDetails details) {
                          if (details.targetElement ==
                              CalendarElement.appointment) {
                            final meeting =
                                details.appointments!.first as Meeting;
                            final BuildContext contextScreen = context;
                            _showAgendamentoDialog(contextScreen, meeting);
                          } else if (details.targetElement ==
                              CalendarElement.calendarCell) {
                            context.pushReplacement(
                              '/agendamento/new',
                              extra: {'data': details.date},
                            );
                          }
                        },
                        monthViewSettings: MonthViewSettings(showAgenda: true),
                        scheduleViewSettings: ScheduleViewSettings(
                          dayHeaderSettings: DayHeaderSettings(),
                        ),
                        view: CalendarView.day,
                        allowViewNavigation: false,
                        showCurrentTimeIndicator: true,
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          timelineAppointmentHeight: 500,
                          timeInterval: Duration(minutes: 30),
                          timeFormat: 'HH:mm',
                        ),
                        showNavigationArrow: true,
                        allowedViews: [
                          CalendarView.day,
                          CalendarView.week,
                          CalendarView.month,
                        ],
                        dataSource: state.data,
                        appointmentBuilder:
                            (context, calendarAppointmentDetails) {
                              final Meeting meeting =
                                  calendarAppointmentDetails.appointments.first
                                      as Meeting;
                              return Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: meeting.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: meeting.status == 'concluido',
                                      side: const BorderSide(
                                        color: Colors.white,
                                      ),
                                      onChanged: (bool? value) {
                                        if ((value ?? false)) {
                                          BuildContext contextScreen = context;
                                          _showAdicionarPagamentoDialog(
                                            contextScreen,
                                            meeting,
                                            value ?? false,
                                          );
                                        }
                                      },
                                    ),

                                    Column(
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

  Future<dynamic> _showAdicionarPagamentoDialog(
    BuildContext contextScreen,
    Meeting meeting,
    bool value,
  ) async {
    return showDialog<void>(
      context: contextScreen,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Adicionar pagamento',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoSelectComponent<String>(
                items: [
                  CampoSelectItem<String>(label: 'Dinheiro', value: 'dinheiro'),
                  CampoSelectItem<String>(
                    label: 'Cartão de Crédito',
                    value: 'cartao_credito',
                  ),
                  CampoSelectItem<String>(
                    label: 'Cartão de Débito',
                    value: 'cartao_debito',
                  ),
                  CampoSelectItem<String>(label: 'Boleto', value: 'boleto'),
                  CampoSelectItem<String>(label: 'Pix', value: 'pix'),
                  CampoSelectItem<String>(
                    label: 'Pix Particular',
                    value: 'pix_particular',
                  ),
                ],
                label: "Forma de pagamento",
                value: meeting.formaPagamento,
                onChange: (value) {
                  meeting.formaPagamento = value;
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Cores.secondaryText,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Cores.positiveColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
              onPressed: () async {
                meeting.status = value ? 'concluido' : 'agendado';
                meeting.background = value
                    ? Cores.positiveColor
                    : Cores.scheduleColor;
                Navigator.of(context).pop();
                bool result = await contextScreen
                    .read<AgendamentoCalendarioController>()
                    .updateAgendamentos(meeting);
                if (result && contextScreen.mounted) {
                  ScaffoldMessenger.of(contextScreen).showSnackBar(
                    SnackBar(
                      content: Text('Agendamento atualizado com sucesso'),
                      backgroundColor: Cores.positiveColor,
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

  Future<void> _showAgendamentoDialog(
    BuildContext contextScreen,
    Meeting meeting,
  ) {
    return showDialog<void>(
      context: contextScreen,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AgendamentoDialog(
          contextScreen: contextScreen,
          cliente: meeting.cliente,
          servicos: meeting.servicos,
          dataFim: meeting.to.toString(),
          dataInicio: meeting.from.toString(),
          observacao: meeting.observacao,
          status: meeting.status,
          uid: meeting.uid,
          valorTotal: meeting.valorTotal,
          buttons: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Cores.negativeColor,
                      Cores.negativeColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Cores.negativeColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    bool result = await contextScreen
                        .read<AgendamentoCalendarioController>()
                        .deleteAgendamento(meeting.uid);
                    if (result && contextScreen.mounted) {
                      ScaffoldMessenger.of(contextScreen).showSnackBar(
                        SnackBar(
                          content: Text('Agendamento excluído com sucesso'),
                          backgroundColor: Cores.positiveColor,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (meeting.status != 'concluido')
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Cores.primaryColor,
                        Cores.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Cores.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.pop();
                      contextScreen.pushReplacement(
                        '/agendamento/${meeting.uid}',
                      );
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
