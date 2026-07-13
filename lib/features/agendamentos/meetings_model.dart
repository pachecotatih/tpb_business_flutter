import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from ?? DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to ?? DateTime.now();
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background ?? Cores.principalText;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  Meeting({
    this.eventName = '',
    this.from,
    this.to,
    this.background,
    this.isAllDay = false,
    this.uid = '',
    this.status = 'pendente',
    this.observacao = '',
    this.servicos = const [],
    this.cliente,
    this.valorTotal = 0,
    this.clienteId = 0,
  });
  String status;

  String uid;

  String observacao;

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime? from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime? to;

  /// Background which is equivalent to color property of [Appointment].
  Color? background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay = false;

  List<ServicoModel> servicos = [];

  ClienteModel? cliente;

  double valorTotal = 0;

  int clienteId = 0;
  String formaPagamento = 'dinheiro';
}
