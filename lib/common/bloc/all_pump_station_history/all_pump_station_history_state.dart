import 'package:demo_app/data/models/pump_station_history.dart';

abstract class AllPumpStationHistoryState {}

class AllPumpStationHistoryInitialState extends AllPumpStationHistoryState {}

class AllPumpStationHistoryLoadingState extends AllPumpStationHistoryState {}

class AllPumpStationHistoryLoadedState extends AllPumpStationHistoryState {
  final List<PumpStationHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  AllPumpStationHistoryLoadedState({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class AllPumpStationHistoryErrorState extends AllPumpStationHistoryState {
  final String errorMessage;

  AllPumpStationHistoryErrorState({required this.errorMessage});
}
