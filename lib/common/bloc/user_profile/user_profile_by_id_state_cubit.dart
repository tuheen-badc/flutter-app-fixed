// user_profile_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/user_profile/user_profile_by_id_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitialState());

  void loadUserProfile({required UseCase useCase, required int userId}) async {
    emit(UserProfileLoadingState());
    try {
      Either result = await useCase.call(param: userId);
      result.fold(
        (error) {
          emit(UserProfileErrorState(errorMessage: error));
        },
        (data) {
          emit(UserProfileLoadedState(user: data));
        },
      );
    } catch (e) {
      emit(UserProfileErrorState(errorMessage: e.toString()));
    }
  }
}
