// reset_password_payload.dart
class ResetPasswordPayload {
  final String token;
  final String newPassword;

  ResetPasswordPayload({required this.token, required this.newPassword});

  Map<String, dynamic> toMap() {
    return {'token': token, 'newPassword': newPassword};
  }
}
