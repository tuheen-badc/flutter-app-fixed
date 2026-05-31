// common/bloc/single_pump_station_history/single_pump_station_history_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/single_pump_station_history/single_pump_station_history_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SinglePumpStationHistoryCubit
    extends Cubit<SinglePumpStationHistoryState> {
  SinglePumpStationHistoryCubit()
    : super(SinglePumpStationHistoryInitialState());

  Future<void> loadSinglePumpStationHistory({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(SinglePumpStationHistoryLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(SinglePumpStationHistoryErrorState(errorMessage: error));
        },
        (data) {
          emit(
            SinglePumpStationHistoryLoadedState(
              historyList: data.historyList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(SinglePumpStationHistoryErrorState(errorMessage: e.toString()));
    }
  }

  void refreshHistory({required UseCase useCase, dynamic params}) {
    loadSinglePumpStationHistory(useCase: useCase, params: params);
  }
}
