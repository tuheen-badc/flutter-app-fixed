class UpdatePhonePayload {
  final String newPhoneNumber;

  UpdatePhonePayload({required this.newPhoneNumber});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'newPhoneNumber': newPhoneNumber};
  }
}
