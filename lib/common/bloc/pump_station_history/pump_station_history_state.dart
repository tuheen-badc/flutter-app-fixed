import 'package:demo_app/data/models/pump_station_history.dart';

abstract class PumpStationHistoryState {}

class PumpStationHistoryInitialState extends PumpStationHistoryState {}

class PumpStationHistoryLoadingState extends PumpStationHistoryState {}

class PumpStationHistoryLoadedState extends PumpStationHistoryState {
  final List<PumpStationHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PumpStationHistoryLoadedState({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class PumpStationHistoryErrorState extends PumpStationHistoryState {
  final String errorMessage;

  PumpStationHistoryErrorState({required this.errorMessage});
}
