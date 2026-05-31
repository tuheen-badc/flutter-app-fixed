import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/login/login_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/error_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButtonStateCubit extends Cubit<LoginButtonState> {
  LoginButtonStateCubit() : super(LoginButtonInitialState());

  void execute({dynamic params, required UseCase useCase}) async {
    emit(LoginButtonLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(LoginFailureState(errorModel: error));
        },
        (data) {
          emit(LoginSuccessState());
        },
      );
    } catch (e) {
      emit(
        LoginFailureState(
          errorModel: ErrorModel(code: 500, message: "Something Went Wrong!"),
        ),
      );
    }
  }

  void reset() {
    emit(LoginButtonInitialState());
  }
}
