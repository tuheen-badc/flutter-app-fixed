// single_pump_station_history_state_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'all_pump_station_history_state.dart';

class AllPumpStationHistoryCubit extends Cubit<AllPumpStationHistoryState> {
  AllPumpStationHistoryCubit() : super(AllPumpStationHistoryInitialState());

  void loadPumpStationHistory({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(AllPumpStationHistoryLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(AllPumpStationHistoryErrorState(errorMessage: error));
        },
        (data) {
          // Parse the response data
          emit(
            AllPumpStationHistoryLoadedState(
              historyList: data.historyList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(AllPumpStationHistoryErrorState(errorMessage: e.toString()));
    }
  }

  void refreshHistory({required UseCase useCase, dynamic params}) {
    loadPumpStationHistory(useCase: useCase, params: params);
  }
}
