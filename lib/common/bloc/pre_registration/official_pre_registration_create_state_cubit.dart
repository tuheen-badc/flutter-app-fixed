// official_pre_registration_create_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'official_pre_registration_create_state.dart';

class OfficialPreRegistrationCreateCubit
    extends Cubit<OfficialPreRegistrationCreateState> {
  OfficialPreRegistrationCreateCubit()
    : super(OfficialPreRegistrationCreateInitialState());

  void createRegistration({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(OfficialPreRegistrationCreateLoadingState());

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(OfficialPreRegistrationCreateFailureState(errorMessage: error));
        },
        (data) {
          emit(
            OfficialPreRegistrationCreateSuccessState(
              message: 'Registration created successfully!',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        OfficialPreRegistrationCreateFailureState(errorMessage: e.toString()),
      );
    }
  }

  void resetState() {
    emit(OfficialPreRegistrationCreateInitialState());
  }
}
