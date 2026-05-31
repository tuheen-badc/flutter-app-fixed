import 'package:demo_app/data/models/office_creation_response.dart';

abstract class CreateOfficeState {}

class CreateOfficeInitialState extends CreateOfficeState {}

class CreateOfficeLoadingState extends CreateOfficeState {}

class CreateOfficeSuccessState extends CreateOfficeState {
  final OfficeCreationResponse office;

  CreateOfficeSuccessState({required this.office});
}

class CreateOfficeErrorState extends CreateOfficeState {
  final String errorMessage;

  CreateOfficeErrorState({required this.errorMessage});
}
