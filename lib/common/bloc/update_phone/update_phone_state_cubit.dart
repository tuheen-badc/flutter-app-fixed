import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/update_phone/update_phone_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';

class UpdatePhoneScreenCubit extends Cubit<UpdatePhoneScreenState> {
  UpdatePhoneScreenCubit() : super(UpdatePhoneScreenInitialState());

  void loadPhone({required UseCase useCase, dynamic params}) async {
    emit(UpdatePhoneScreenLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdatePhoneScreenFailureState(errorMessage: error));
        },
        (data) {
          emit(UpdatePhoneScreenSuccessState(phone: data.phone));
        },
      );
    } catch (e) {
      emit(UpdatePhoneScreenFailureState(errorMessage: e.toString()));
    }
  }
}

class UpdatePhoneButtonStateCubit extends Cubit<UpdatePhoneButtonState> {
  UpdatePhoneButtonStateCubit() : super(UpdatePhoneButtonInitialState());

  Future<void> updatePhone({dynamic params, required UseCase useCase}) async {
    emit(UpdatePhoneButtonLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdatePhoneButtonFailureState(errorMessage: error));
        },
        (data) {
          emit(UpdatePhoneButtonSuccessState());
        },
      );
    } catch (e) {
      emit(UpdatePhoneButtonFailureState(errorMessage: e.toString()));
    }
  }
}
