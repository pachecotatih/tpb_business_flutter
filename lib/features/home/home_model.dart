import 'package:tpb_business_flutter/features/agendamentos/agendamento_model.dart';

class HomeModel {
  double? saldoHoje;
  double? entradasHoje;
  double? saidasHoje;

  List<AgendamentoModel>? agendamentosHoje;

  HomeModel({
    this.saldoHoje,
    this.entradasHoje,
    this.saidasHoje,
    this.agendamentosHoje,
  });

  HomeModel.fromJson(Map<String, dynamic> json) {
    saldoHoje = double.parse((json['saldo_hoje'] ?? 0).toString());
    entradasHoje = double.parse((json['entradas_hoje'] ?? 0).toString());
    saidasHoje = double.parse((json['saidas_hoje'] ?? 0).toString());
    if (json['agendamentos_hoje'] != null) {
      agendamentosHoje = <AgendamentoModel>[];
      json['agendamentos_hoje'].forEach((v) {
        agendamentosHoje!.add(AgendamentoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
    'saldo_hoje': saldoHoje,
    'entradas_hoje': entradasHoje,
    'saidas_hoje': saidasHoje,
    'agendamentos_hoje': agendamentosHoje,
  };
}
