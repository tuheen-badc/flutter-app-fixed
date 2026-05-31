import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/create_office/create_office_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/office_creation_payload.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateOfficeCubit extends Cubit<CreateOfficeState> {
  CreateOfficeCubit() : super(CreateOfficeInitialState());

  void createOffice({
    required UseCase useCase,
    required OfficeCreationPayload params,
  }) async {
    emit(CreateOfficeLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(CreateOfficeErrorState(errorMessage: error));
        },
        (data) {
          emit(CreateOfficeSuccessState(office: data));
        },
      );
    } catch (e) {
      emit(CreateOfficeErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() {
    emit(CreateOfficeInitialState());
  }
}
