// Update name screen state
abstract class UpdateNameScreenState {}

class UpdateNameScreenInitialState extends UpdateNameScreenState {}

class UpdateNameScreenLoadingState extends UpdateNameScreenState {}

class UpdateNameScreenLoadedState extends UpdateNameScreenState {
  final String firstName;
  final String lastName;

  UpdateNameScreenLoadedState({
    required this.firstName,
    required this.lastName,
  });
}

class UpdateNameScreenErrorState extends UpdateNameScreenState {
  final String errorMessage;

  UpdateNameScreenErrorState({required this.errorMessage});
}

// Button states for update action
abstract class UpdateNameButtonState {}

class UpdateNameButtonInitialState extends UpdateNameButtonState {}

class UpdateNameButtonLoadingState extends UpdateNameButtonState {}

class UpdateNameButtonSuccessState extends UpdateNameButtonState {}

class UpdateNameButtonFailureState extends UpdateNameButtonState {
  final String errorMessage;

  UpdateNameButtonFailureState({required this.errorMessage});
}
