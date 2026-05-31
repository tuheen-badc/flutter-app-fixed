class VerifyForgotPasswordResponse {
  final String token;

  VerifyForgotPasswordResponse({required this.token});

  factory VerifyForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return VerifyForgotPasswordResponse(token: json['token'] ?? '');
  }
}
