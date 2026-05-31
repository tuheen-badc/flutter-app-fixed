// pump_live_status_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/user_pump_live_status/user_pump_live_status_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpLiveStatusCubit extends Cubit<PumpLiveStatusState> {
  PumpLiveStatusCubit() : super(PumpLiveStatusInitialState());

  void loadLiveStatus({required UseCase useCase, required int userId}) async {
    emit(PumpLiveStatusLoadingState());
    try {
      Either result = await useCase.call(param: userId);
      result.fold(
        (error) => emit(PumpLiveStatusErrorState(errorMessage: error)),
        (data) => emit(PumpLiveStatusLoadedState(data: data)),
      );
    } catch (e) {
      emit(PumpLiveStatusErrorState(errorMessage: e.toString()));
    }
  }
}
