class ServicoModel {
  String uid;
  String nome;
  double? valorPadrao;
  String? duracaoPadrao;
  bool ativo;

  ServicoModel({
    this.uid = '',
    this.nome = '',
    this.valorPadrao,
    this.duracaoPadrao,
    this.ativo = true,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      uid: json['uid'],
      nome: json['nome'],
      valorPadrao: double.parse((json['valor_padrao'] ?? "0").toString()),
      duracaoPadrao: json['duracao_padrao'],
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'valor_padrao': valorPadrao,
      'duracao_padrao': duracaoPadrao,
      'ativo': ativo,
    };
  }
}
