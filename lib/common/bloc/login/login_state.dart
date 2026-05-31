import 'package:demo_app/data/models/error_model.dart';

abstract class LoginButtonState {}

class LoginButtonInitialState extends LoginButtonState {}

class LoginButtonLoadingState extends LoginButtonState {}

class LoginSuccessState extends LoginButtonState {}

class LoginFailureState extends LoginButtonState {
  final ErrorModel errorModel;

  LoginFailureState({required this.errorModel});
}
