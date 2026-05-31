// water_pricing_update_state.dart
abstract class FirmwareUploadState {}

class FirmwareUploadInitialState extends FirmwareUploadState {}

class FirmwareUploadLoadingState extends FirmwareUploadState {}

class FirmwareUploadSuccessState extends FirmwareUploadState {
  final String message;

  FirmwareUploadSuccessState({required this.message});
}

class FirmwareUploadErrorState extends FirmwareUploadState {
  final String errorMessage;

  FirmwareUploadErrorState({required this.errorMessage});
}