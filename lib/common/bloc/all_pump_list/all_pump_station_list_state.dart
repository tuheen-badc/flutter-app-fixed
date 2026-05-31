import '../../../data/models/pump_station_list.dart';

abstract class AllPumpStationState {}

class AllPumpStationInitialState extends AllPumpStationState {}

class AllPumpStationLoadingState extends AllPumpStationState {}

class AllPumpStationLoadedState extends AllPumpStationState {
  final List<PumpStationItem> stationList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  AllPumpStationLoadedState({
    required this.stationList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  AllPumpStationLoadedState copyWith({
    List<PumpStationItem>? stationList,
    int? totalElements,
    int? totalPages,
    int? currentPage,
  }) {
    return AllPumpStationLoadedState(
      stationList: stationList ?? this.stationList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class AllPumpStationErrorState extends AllPumpStationState {
  final String errorMessage;

  AllPumpStationErrorState({required this.errorMessage});
}
