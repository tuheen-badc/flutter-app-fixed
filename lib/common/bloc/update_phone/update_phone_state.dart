import '../../../data/models/user_info.dart';

abstract class UpdatePhoneScreenState {}

class UpdatePhoneScreenInitialState extends UpdatePhoneScreenState {}

class UpdatePhoneScreenLoadingState extends UpdatePhoneScreenState {}

class UpdatePhoneScreenSuccessState extends UpdatePhoneScreenState {
  final String phone;

  UpdatePhoneScreenSuccessState({required this.phone});
}

class UpdatePhoneScreenFailureState extends UpdatePhoneScreenState {
  final String errorMessage;

  UpdatePhoneScreenFailureState({required this.errorMessage});
}

abstract class UpdatePhoneButtonState {}

class UpdatePhoneButtonInitialState extends UpdatePhoneButtonState {}

class UpdatePhoneButtonLoadingState extends UpdatePhoneButtonState {}

class UpdatePhoneButtonSuccessState extends UpdatePhoneButtonState {}

class UpdatePhoneButtonFailureState extends UpdatePhoneButtonState {
  final String errorMessage;

  UpdatePhoneButtonFailureState({required this.errorMessage});
}
