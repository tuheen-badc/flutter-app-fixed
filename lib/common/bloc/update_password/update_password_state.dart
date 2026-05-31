// common/bloc/change_password/change_password_state.dart
abstract class UpdatePasswordButtonState {}

class UpdatePasswordButtonInitialState extends UpdatePasswordButtonState {}

class UpdatePasswordButtonLoadingState extends UpdatePasswordButtonState {}

class UpdatePasswordButtonSuccessState extends UpdatePasswordButtonState {}

class UpdatePasswordButtonFailureState extends UpdatePasswordButtonState {
  final String errorMessage;

  UpdatePasswordButtonFailureState({required this.errorMessage});
}
