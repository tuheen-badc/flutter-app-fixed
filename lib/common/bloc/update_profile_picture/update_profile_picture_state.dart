abstract class UpdateProfilePictureButtonState {}

class UpdateProfilePictureButtonInitialState
    extends UpdateProfilePictureButtonState {}

class UpdateProfilePictureButtonLoadingState
    extends UpdateProfilePictureButtonState {}

class UpdateProfilePictureButtonSuccessState
    extends UpdateProfilePictureButtonState {}

class UpdateProfilePictureButtonFailureState
    extends UpdateProfilePictureButtonState {
  final String errorMessage;

  UpdateProfilePictureButtonFailureState({required this.errorMessage});
}
