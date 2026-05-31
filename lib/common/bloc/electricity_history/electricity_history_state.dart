// user_pump_live_status_state.dart
import '../../../data/models/electricity_history.dart';

abstract class ElectricityHistoryState {}

class ElectricityHistoryInitialState extends ElectricityHistoryState {}

class ElectricityHistoryLoadingState extends ElectricityHistoryState {}

class ElectricityHistoryLoadedState extends ElectricityHistoryState {
  final List<ElectricityStatusHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ElectricityHistoryLoadedState({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  ElectricityHistoryLoadedState copyWith({
    List<ElectricityStatusHistoryItem>? historyList,
    int? totalElements,
    int? totalPages,
    int? currentPage,
  }) {
    return ElectricityHistoryLoadedState(
      historyList: historyList ?? this.historyList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ElectricityHistoryErrorState extends ElectricityHistoryState {
  final String errorMessage;

  ElectricityHistoryErrorState({required this.errorMessage});
}
