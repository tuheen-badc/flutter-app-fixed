// official_pre_registration_delete_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'official_pre_registration_delete_state.dart';

class OfficialPreRegistrationDeleteCubit
    extends Cubit<OfficialPreRegistrationDeleteState> {
  OfficialPreRegistrationDeleteCubit()
    : super(OfficialPreRegistrationDeleteInitialState());

  void deleteRegistration({
    required UseCase useCase,
    required int registrationId,
  }) async {
    emit(
      OfficialPreRegistrationDeleteLoadingState(registrationId: registrationId),
    );

    try {
      Either result = await useCase.call(param: registrationId);

      result.fold(
        (error) {
          emit(
            OfficialPreRegistrationDeleteFailureState(
              registrationId: registrationId,
              errorMessage: error,
            ),
          );
        },
        (data) {
          emit(
            OfficialPreRegistrationDeleteSuccessState(
              registrationId: registrationId,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        OfficialPreRegistrationDeleteFailureState(
          registrationId: registrationId,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetState() {
    emit(OfficialPreRegistrationDeleteInitialState());
  }
}
