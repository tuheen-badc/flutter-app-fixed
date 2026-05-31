class LoginPayload {
  final String phone;
  final String password;

  LoginPayload({required this.phone, required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phone': phone, 'password': password};
  }
}
