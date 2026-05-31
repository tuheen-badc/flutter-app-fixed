// official_pre_registration_state.dart
import '../../../data/models/official_pre_registration.dart';

abstract class OfficialPreRegistrationState {}

class OfficialPreRegistrationInitialState
    extends OfficialPreRegistrationState {}

class OfficialPreRegistrationLoadingState
    extends OfficialPreRegistrationState {}

class OfficialPreRegistrationLoadedState extends OfficialPreRegistrationState {
  final List<OfficialPreRegistrationItem> registrationList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficialPreRegistrationLoadedState({
    required this.registrationList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  OfficialPreRegistrationLoadedState copyWith({
    List<OfficialPreRegistrationItem>? registrationList,
    int? totalElements,
    int? totalPages,
    int? currentPage,
  }) {
    return OfficialPreRegistrationLoadedState(
      registrationList: registrationList ?? this.registrationList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OfficialPreRegistrationErrorState extends OfficialPreRegistrationState {
  final String errorMessage;

  OfficialPreRegistrationErrorState({required this.errorMessage});
}
