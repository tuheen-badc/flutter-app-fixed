import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_list/pump_control_button_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_execution_request_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpControlButtonCubit extends Cubit<PumpControlButtonState> {
  PumpControlButtonCubit() : super(PumpControlButtonInitialState());

  void togglePumpStation({
    required UseCase useCase,
    required int stationId,
    dynamic params,
  }) async {
    emit(PumpControlButtonLoadingState(stationId: stationId));

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(
            PumpControlButtonFailureState(
              stationId: stationId,
              errorMessage: error,
            ),
          );
        },
        (data) {
          // Determine if this is a start request based on the type
          final isRunning = data.type == PumpExecutionRequestType.START;

          emit(
            PumpControlButtonSuccessState(
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
        PumpControlButtonFailureState(
          stationId: stationId,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetState() {
    emit(PumpControlButtonInitialState());
  }
}
