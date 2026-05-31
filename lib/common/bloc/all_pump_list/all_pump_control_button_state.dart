// complaint_state.dart
import 'package:demo_app/data/models/pump_execution_request_type.dart';

abstract class AllPumpControlButtonState {}

class AllPumpControlButtonInitialState extends AllPumpControlButtonState {}

class AllPumpControlButtonLoadingState extends AllPumpControlButtonState {
  final int stationId;

  AllPumpControlButtonLoadingState({required this.stationId});
}

class AllPumpControlButtonSuccessState extends AllPumpControlButtonState {
  final int stationId;
  final PumpExecutionRequestType type;
  final DateTime requestTime;
  final bool isRunning;

  AllPumpControlButtonSuccessState({
    required this.stationId,
    required this.type,
    required this.requestTime,
    required this.isRunning,
  });
}

class AllPumpControlButtonFailureState extends AllPumpControlButtonState {
  final int stationId;
  final String errorMessage;

  AllPumpControlButtonFailureState({
    required this.stationId,
    required this.errorMessage,
  });
}
