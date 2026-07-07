class LoginModel {
  String email;
  String name;
  String documento;
  String telefone;
  String password;
  String deviceId;
  String deviceName;
  LoginModel({
    this.email = '',
    this.password = '',
    this.deviceId = '',
    this.deviceName = '',
    this.name = '',
    this.documento = '',
    this.telefone = '',
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'],
      password: json['password'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      name: json['name'],
      documento: json['documento'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_id': deviceId,
      'device_name': deviceName,
      'name': name,
      'documento': documento,
      'telefone': telefone,
    };
  }
}
