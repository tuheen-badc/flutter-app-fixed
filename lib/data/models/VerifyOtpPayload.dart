class VerifyOtpPayload {
  final String phone;
  final String otpCode;

  VerifyOtpPayload({required this.phone, required this.otpCode});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'phone': phone, 'otpCode': otpCode};
  }
}
