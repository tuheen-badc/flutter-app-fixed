// pump_live_status_state.dart
import '../../../data/models/pump_live_status_model.dart';

abstract class PumpLiveStatusState {}

class PumpLiveStatusInitialState extends PumpLiveStatusState {}

class PumpLiveStatusLoadingState extends PumpLiveStatusState {}

class PumpLiveStatusLoadedState extends PumpLiveStatusState {
  final PumpLiveStatusResponse data;

  PumpLiveStatusLoadedState({required this.data});
}

class PumpLiveStatusErrorState extends PumpLiveStatusState {
  final String errorMessage;

  PumpLiveStatusErrorState({required this.errorMessage});
}
