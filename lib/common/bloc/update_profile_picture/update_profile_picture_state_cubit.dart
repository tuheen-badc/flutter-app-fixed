// common/bloc/update_profile_picture/update_profile_picture_state_cubit.dart
import 'package:demo_app/common/bloc/update_profile_picture/update_profile_picture_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';

class UpdateProfilePictureButtonStateCubit
    extends Cubit<UpdateProfilePictureButtonState> {
  UpdateProfilePictureButtonStateCubit()
    : super(UpdateProfilePictureButtonInitialState());

  Future<void> updateProfilePicture({
    dynamic params,
    required UseCase useCase,
  }) async {
    emit(UpdateProfilePictureButtonLoadingState());

    try {
      final result = await useCase.call(param: params);

      result.fold(
        (failure) {
          emit(
            UpdateProfilePictureButtonFailureState(
              errorMessage:
                  failure.message ?? 'Failed to update profile picture',
            ),
          );
        },
        (success) {
          emit(UpdateProfilePictureButtonSuccessState());
        },
      );
    } catch (e) {
      emit(
        UpdateProfilePictureButtonFailureState(
          errorMessage: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }
}
