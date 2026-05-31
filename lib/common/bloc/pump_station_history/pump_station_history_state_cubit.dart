// single_pump_station_history_state_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_station_history/pump_station_history_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpStationHistoryCubit extends Cubit<PumpStationHistoryState> {
  PumpStationHistoryCubit() : super(PumpStationHistoryInitialState());

  void loadPumpStationHistory({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(PumpStationHistoryLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(PumpStationHistoryErrorState(errorMessage: error));
        },
        (data) {
          // Parse the response data
          emit(
            PumpStationHistoryLoadedState(
              historyList: data.historyList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(PumpStationHistoryErrorState(errorMessage: e.toString()));
    }
  }

  void refreshHistory({required UseCase useCase, dynamic params}) {
    loadPumpStationHistory(useCase: useCase, params: params);
  }
}
