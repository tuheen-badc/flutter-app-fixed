// user_pump_live_status_state.dart
abstract class VerifyOtpButtonState {}

class VerifyOtpButtonInitialState extends VerifyOtpButtonState {}

class VerifyOtpButtonLoadingState extends VerifyOtpButtonState {}

class VerifyOtpButtonSuccessState extends VerifyOtpButtonState {
  final dynamic data; // Generic data from API response

  VerifyOtpButtonSuccessState({this.data});
}

class VerifyOtpButtonFailureState extends VerifyOtpButtonState {
  final String errorMessage;

  VerifyOtpButtonFailureState({required this.errorMessage});
}
