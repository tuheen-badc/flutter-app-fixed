// common/bloc/single_pump_station_history/single_pump_station_history_state.dart
import '../../../data/models/pump_station_history.dart';

abstract class SinglePumpStationHistoryState {}

class SinglePumpStationHistoryInitialState
    extends SinglePumpStationHistoryState {}

class SinglePumpStationHistoryLoadingState
    extends SinglePumpStationHistoryState {}

class SinglePumpStationHistoryLoadedState
    extends SinglePumpStationHistoryState {
  final List<PumpStationHistoryItem> historyList;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  SinglePumpStationHistoryLoadedState({
    required this.historyList,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

class SinglePumpStationHistoryErrorState extends SinglePumpStationHistoryState {
  final String errorMessage;

  SinglePumpStationHistoryErrorState({required this.errorMessage});
}
