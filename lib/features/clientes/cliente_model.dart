class ClienteModel {
  String uid;
  String nome;
  String? email;
  String? telefone;
  String? documento;
  String? dataNascimento;
  String? tipo;
  String? observacao;

  ClienteModel({
    this.uid = '',
    this.nome = '',
    this.email = '',
    this.telefone = '',
    this.documento = '',
    this.dataNascimento = '',
    this.tipo = 'PF',
    this.observacao = '',
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      uid: json['uid'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      documento: json['documento'],
      dataNascimento: json['data_nascimento'],
      tipo: json['tipo'],
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'documento': documento,
      'data_nascimento': dataNascimento,
      'tipo': tipo,
      'observacao': observacao,
    };
  }
}
