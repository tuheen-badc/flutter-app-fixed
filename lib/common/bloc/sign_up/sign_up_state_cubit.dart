import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/sign_up/sign_up_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpButtonStateCubit extends Cubit<SignUpButtonState> {
  SignUpButtonStateCubit() : super(SignUpButtonInitialState());

  void execute({dynamic params, required UseCase useCase}) async {
    emit(SignUpButtonLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SignUpFailureState(errorMessage: error));
        },
        (data) {
          emit(SignUpSuccessState());
        },
      );
    } catch (e) {
      emit(SignUpFailureState(errorMessage: e.toString()));
    }
  }
}
