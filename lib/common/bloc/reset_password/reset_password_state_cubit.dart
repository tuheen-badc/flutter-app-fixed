// reset_password_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/reset_password/reset_password_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitialState());

  void resetPassword({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(ResetPasswordLoadingState());

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(ResetPasswordErrorState(errorMessage: error));
        },
        (data) {
          // Success - password reset complete
          emit(ResetPasswordSuccessState());
        },
      );
    } catch (e) {
      emit(ResetPasswordErrorState(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ResetPasswordInitialState());
  }
}
