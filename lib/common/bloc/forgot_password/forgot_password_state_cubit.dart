// forgot_password_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitialState());

  void sendOtp({required UseCase useCase, dynamic params}) async {
    emit(ForgotPasswordLoadingState());

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(ForgotPasswordErrorState(errorMessage: error));
        },
        (data) {
          // Success - just OK status
          emit(ForgotPasswordSuccessState());
        },
      );
    } catch (e) {
      emit(ForgotPasswordErrorState(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ForgotPasswordInitialState());
  }
}
