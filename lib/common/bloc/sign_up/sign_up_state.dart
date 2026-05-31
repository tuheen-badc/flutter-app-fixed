abstract class SignUpButtonState {}

class SignUpButtonInitialState extends SignUpButtonState {}

class SignUpButtonLoadingState extends SignUpButtonState {}

class SignUpSuccessState extends SignUpButtonState {}

class SignUpFailureState extends SignUpButtonState {
  final String errorMessage;

  SignUpFailureState({required this.errorMessage});
}
