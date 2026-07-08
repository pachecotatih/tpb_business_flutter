class UserModel {
  String name;
  String email;
  String telefone;
  String documento;
  String moeda;
  String password;
  String? confirmPassword;

  UserModel({
    this.name = '',
    this.email = '',
    this.telefone = '',
    this.documento = '',
    this.moeda = "R\$",
    this.password = '',
    this.confirmPassword,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      telefone: json['telefone'],
      documento: json['documento'],
      moeda: json['moeda'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['telefone'] = telefone;
    data['documento'] = documento;
    data['moeda'] = moeda;
    data['password'] = password;
    return data;
  }
}
