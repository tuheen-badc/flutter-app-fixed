import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/all_pump_list/all_pump_control_button_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_execution_request_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllPumpControlButtonCubit extends Cubit<AllPumpControlButtonState> {
  AllPumpControlButtonCubit() : super(AllPumpControlButtonInitialState());

  void togglePumpStation({
    required UseCase useCase,
    required int stationId,
    dynamic params,
  }) async {
    emit(AllPumpControlButtonLoadingState(stationId: stationId));

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(
            AllPumpControlButtonFailureState(
              stationId: stationId,
              errorMessage: error,
            ),
          );
        },
        (data) {
          // Determine if this is a start request based on the type
          final isRunning = data.type == PumpExecutionRequestType.START;

          emit(
            AllPumpControlButtonSuccessState(
              stationId: stationId,
              requestTime: data.requestTime,
              type: data.type,
              isRunning: isRunning,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        AllPumpControlButtonFailureState(
          stationId: stationId,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetState() {
    emit(AllPumpControlButtonInitialState());
  }
}
