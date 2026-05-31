// user_pump_live_status_state_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/otp_validation/verify_otp_button_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyOtpButtonStateCubit extends Cubit<VerifyOtpButtonState> {
  VerifyOtpButtonStateCubit() : super(VerifyOtpButtonInitialState());

  void execute({required UseCase useCase, dynamic params}) async {
    emit(VerifyOtpButtonLoadingState());

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(VerifyOtpButtonFailureState(errorMessage: error));
        },
        (data) {
          // Pass the data to the success state
          emit(VerifyOtpButtonSuccessState(data: data));
        },
      );
    } catch (e) {
      emit(VerifyOtpButtonFailureState(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(VerifyOtpButtonInitialState());
  }
}
