import 'package:tpb_business_flutter/features/clientes/cliente_model.dart';

class FluxoCaixaModel {
  double saldo;
  double totalEntradas;
  double totalSaidas;
  List<FluxoCaixaItemModel>? fluxoCaixaList;
  List<FluxoCaixaGrupoModel>? grupos;

  String? dataInicio;
  String? dataFim;
  String? tipoMovimentacao;
  String? formaPagamento;

  FluxoCaixaModel({
    this.saldo = 0,
    this.totalEntradas = 0,
    this.totalSaidas = 0,
    this.fluxoCaixaList,
  });

  factory FluxoCaixaModel.fromJson(Map<String, dynamic> json) {
    return FluxoCaixaModel(
      saldo: double.parse((json['saldo'] ?? 0).toString()),
      totalEntradas: double.parse((json['total_entradas'] ?? 0).toString()),
      totalSaidas: double.parse((json['total_saidas'] ?? 0).toString()),
      fluxoCaixaList: json['fluxo_caixa_list'] != null
          ? (json['fluxo_caixa_list'] as List)
                .map((i) => FluxoCaixaItemModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class FluxoCaixaGrupoModel {
  final DateTime data;
  final List<FluxoCaixaItemModel> fluxoCaixaList;

  FluxoCaixaGrupoModel({required this.data, required this.fluxoCaixaList});
}

class FluxoCaixaItemModel {
  String? uid;
  String? descricao;
  double? valor;
  String tipoMovimentacao;
  String formaPagamento;
  String? dataVencimento;
  String? dataPagamento;
  bool? pago;
  String? observacao;
  ClienteModel? cliente;
  String? createdAt;

  FluxoCaixaItemModel({
    this.uid,
    this.descricao,
    this.valor,
    this.tipoMovimentacao = 'entrada',
    this.formaPagamento = 'dinheiro',
    this.dataVencimento,
    this.dataPagamento,
    this.pago,
    this.observacao,
    this.cliente,
    this.createdAt,
  });

  factory FluxoCaixaItemModel.fromJson(Map<String, dynamic> json) {
    return FluxoCaixaItemModel(
      uid: json['uid'],
      descricao: json['descricao'],
      valor: double.parse((json['valor'] ?? 0).toString()),
      tipoMovimentacao: json['tipo_movimentacao'] ?? 'entrada',
      formaPagamento: json['forma_pagamento'] ?? 'dinheiro',
      dataVencimento: json['data_vencimento'],
      dataPagamento: json['data_pagamento'],
      pago: json['pago'] ?? false,
      observacao: json['observacao'],
      createdAt: json['created_at'],
      cliente: json['cliente'] != null
          ? ClienteModel.fromJson(json['cliente'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'descricao': descricao,
      'valor': valor,
      'tipo_movimentacao': tipoMovimentacao,
      'forma_pagamento': formaPagamento,
      'data_vencimento': dataVencimento,
      'data_pagamento': dataPagamento,
      'pago': pago,
      'observacao': observacao,
      'created_at': createdAt,
      'cliente': cliente?.toJson(),
    };
  }
}
