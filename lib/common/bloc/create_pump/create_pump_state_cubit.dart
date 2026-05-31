// common/bloc/create_pump/create_pump_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_pump_state.dart';

class CreatePumpCubit extends Cubit<CreatePumpState> {
  CreatePumpCubit() : super(CreatePumpInitialState());

  Future<void> createPump({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(CreatePumpLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) => emit(CreatePumpErrorState(errorMessage: error.toString())),
        (data) => emit(CreatePumpSuccessState(createdStation: data)),
      );
    } catch (e) {
      emit(CreatePumpErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() => emit(CreatePumpInitialState());
}
