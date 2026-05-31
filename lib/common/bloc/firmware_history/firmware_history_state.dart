// water_pricing_update_state.dart
import '../../../data/models/firmware_history_item.dart';

abstract class FirmwareHistoryState {}

class FirmwareHistoryInitialState extends FirmwareHistoryState {}

class FirmwareHistoryLoadingState extends FirmwareHistoryState {}

class FirmwareHistoryLoadedState extends FirmwareHistoryState {
  final List<FirmwareHistoryItem> historyList;

  FirmwareHistoryLoadedState({required this.historyList});
}

class FirmwareHistoryErrorState extends FirmwareHistoryState {
  final String errorMessage;

  FirmwareHistoryErrorState({required this.errorMessage});
}
