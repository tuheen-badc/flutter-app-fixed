import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/login/login_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/error_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButtonStateCubit extends Cubit<LoginButtonState> {
  LoginButtonStateCubit() : super(LoginButtonInitialState());

  void execute({dynamic params, required UseCase useCase}) async {
    emit(LoginButtonLoadingState());

    final startTime = DateTime.now();
    bool finished = false;
    int attempt = 0;

    while (DateTime.now().difference(startTime).inSeconds < 60) {
      attempt++;
      try {
        // Try connection with a timeout of 5 seconds
        Either result = await useCase.call(param: params).timeout(
          const Duration(seconds: 5),
        );

        bool shouldStop = false;
        result.fold(
          (error) {
            // Check if it's a client-side error (e.g., 401 Unauthorized, 400 Bad Request)
            // These errors typically mean retry won't help (wrong credentials, etc.)
            if (error is ErrorModel &&
                error.code >= 400 &&
                error.code < 500) {
              emit(LoginFailureState(errorModel: error));
              shouldStop = true;
              finished = true;
            } else {
              debugPrint(
                "Login attempt $attempt failed with server error: $error. Retrying...",
              );
            }
          },
          (data) {
            emit(LoginSuccessState());
            shouldStop = true;
            finished = true;
          },
        );

        if (shouldStop) return;
      } catch (e) {
        debugPrint(
          "Login attempt $attempt failed with exception: $e. Retrying...",
        );
      }

      // Retry policy:
      // First fail: wait 15 seconds.
      // Subsequent fails: wait 5 seconds.
      if (attempt == 1) {
        await Future.delayed(const Duration(seconds: 15));
      } else {
        await Future.delayed(const Duration(seconds: 5));
      }

      // Check if we still have time for another attempt before loop continues
      if (DateTime.now().difference(startTime).inSeconds >= 60) break;
    }

    if (!finished) {
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
