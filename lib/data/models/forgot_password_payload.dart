class ForgotPasswordPayload {
  final String phone;

  ForgotPasswordPayload({required this.phone});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phone': phone};
  }
}
