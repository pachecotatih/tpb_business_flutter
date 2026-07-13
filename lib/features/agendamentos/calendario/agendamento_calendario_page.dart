import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
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
          title: 'Agendamentos',
          children: [
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SfCalendar(
                view: CalendarView.day,
                dataSource: state.data,
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  final Meeting meeting =
                      calendarAppointmentDetails.appointments.first as Meeting;
                  return Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: meeting.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: meeting.status == 'concluido',
                          onChanged: (bool? value) {
                            setState(() {
                              meeting.status = value!
                                  ? 'concluido'
                                  : 'agendado';
                            });
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return BlocBuilder<
                                  AgendamentoCalendarioController,
                                  StateBloc<MeetingDataSource>
                                >(
                                  builder: (context, state) {
                                    return AlertDialog(
                                      title: const Text('Adicionar pagamento'),
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
                                                label: 'Cartão de Crédito',
                                                value: 'cartao_credito',
                                              ),
                                              CampoSelectItem<String>(
                                                label: 'Cartão de Débito',
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
                                              meeting.formaPagamento = value;
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
                                          onPressed: () {
                                            context
                                                .read<
                                                  AgendamentoCalendarioController
                                                >()
                                                .updateAgendamentos(meeting);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting.eventName,
                                style: TextStyle(
                                  color: Cores.principalText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                meeting.cliente!.telefone ?? "",
                                style: TextStyle(
                                  color: Cores.principalText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                meeting.servicos.join(", "),
                                style: TextStyle(
                                  color: Cores.principalText,
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
