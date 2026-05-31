// official_pre_registration_delete_state.dart
abstract class OfficialPreRegistrationDeleteState {}

class OfficialPreRegistrationDeleteInitialState
    extends OfficialPreRegistrationDeleteState {}

class OfficialPreRegistrationDeleteLoadingState
    extends OfficialPreRegistrationDeleteState {
  final int registrationId;

  OfficialPreRegistrationDeleteLoadingState({required this.registrationId});
}

class OfficialPreRegistrationDeleteSuccessState
    extends OfficialPreRegistrationDeleteState {
  final int registrationId;

  OfficialPreRegistrationDeleteSuccessState({required this.registrationId});
}

class OfficialPreRegistrationDeleteFailureState
    extends OfficialPreRegistrationDeleteState {
  final int registrationId;
  final String errorMessage;

  OfficialPreRegistrationDeleteFailureState({
    required this.registrationId,
    required this.errorMessage,
  });
}