// official_pre_registration_create_state.dart
abstract class OfficialPreRegistrationCreateState {}

class OfficialPreRegistrationCreateInitialState
    extends OfficialPreRegistrationCreateState {}

class OfficialPreRegistrationCreateLoadingState
    extends OfficialPreRegistrationCreateState {}

class OfficialPreRegistrationCreateSuccessState
    extends OfficialPreRegistrationCreateState {
  final String message;

  OfficialPreRegistrationCreateSuccessState({required this.message});
}

class OfficialPreRegistrationCreateFailureState
    extends OfficialPreRegistrationCreateState {
  final String errorMessage;

  OfficialPreRegistrationCreateFailureState({required this.errorMessage});
}
