import '../../../data/models/pump_station_list.dart';

abstract class PumpStationState {}

class PumpStationInitialState extends PumpStationState {}

class PumpStationLoadingState extends PumpStationState {}

class PumpStationLoadedState extends PumpStationState {
  final List<PumpStationItem> stationList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PumpStationLoadedState({
    required this.stationList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  PumpStationLoadedState copyWith({
    List<PumpStationItem>? stationList,
    int? totalElements,
    int? totalPages,
    int? currentPage,
  }) {
    return PumpStationLoadedState(
      stationList: stationList ?? this.stationList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PumpStationErrorState extends PumpStationState {
  final String errorMessage;

  PumpStationErrorState({required this.errorMessage});
}
