import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';
import 'package:tpb_business_flutter/features/servicos/servico_model.dart';

class AgendamentoModel {
  String? uid;
  ClienteModel? cliente;
  String? status;
  String? dataInicio;
  String? dataFim;
  int? clienteId;
  String? observacao;
  double? valorTotal;
  List<ServicoModel>? servicos;
  List<ServicoModel>? servicosInit;
  List<ClienteModel>? clientes;

  int step = 0;

  AgendamentoModel({
    this.uid,
    this.cliente,
    this.status,
    this.dataInicio,
    this.dataFim,
    this.clienteId,
    this.observacao,
    this.valorTotal,
    this.servicos,
  });

  AgendamentoModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    cliente = json['cliente'] != null
        ? ClienteModel.fromJson(json['cliente'])
        : null;
    status = json['status'];
    dataInicio = json['data_inicio'];
    dataFim = json['data_fim'];
    clienteId = json['cliente_id'];
    observacao = json['observacao'];
    valorTotal = json['valor_total'];
    clientes = json['clientes'];
    if (json['servicos'] != null) {
      servicos = <ServicoModel>[];
      json['servicos'].forEach((v) {
        servicos!.add(ServicoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['cliente'] = cliente?.toJson();
    data['status'] = status;
    data['data_inicio'] = dataInicio;
    data['data_fim'] = dataFim;
    data['cliente_id'] = clienteId;
    data['observacao'] = observacao;
    data['valor_total'] = valorTotal;
    data['clientes'] = clientes;
    if (servicos != null) {
      data['servicos'] = servicos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
