class UpdatePasswordPayload {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  UpdatePasswordPayload({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };
  }
}
