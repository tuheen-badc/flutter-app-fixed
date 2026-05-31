// official_pre_registration_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'official_pre_registration.dart';

class OfficialPreRegistrationCubit extends Cubit<OfficialPreRegistrationState> {
  OfficialPreRegistrationCubit() : super(OfficialPreRegistrationInitialState());

  void loadRegistrations({required UseCase useCase, dynamic params}) async {
    emit(OfficialPreRegistrationLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(OfficialPreRegistrationErrorState(errorMessage: error));
        },
        (data) {
          emit(
            OfficialPreRegistrationLoadedState(
              registrationList: data.registrationList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(OfficialPreRegistrationErrorState(errorMessage: e.toString()));
    }
  }
}
