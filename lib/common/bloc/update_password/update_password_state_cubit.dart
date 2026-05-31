import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/update_password/update_password_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatePasswordButtonStateCubit extends Cubit<UpdatePasswordButtonState> {
  UpdatePasswordButtonStateCubit() : super(UpdatePasswordButtonInitialState());

  void updatePassword({dynamic params, required UseCase useCase}) async {
    emit(UpdatePasswordButtonLoadingState());

    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdatePasswordButtonFailureState(errorMessage: error));
        },
        (data) {
          emit(UpdatePasswordButtonSuccessState());
        },
      );
    } catch (e) {
      emit(UpdatePasswordButtonFailureState(errorMessage: e.toString()));
    }
  }
}
