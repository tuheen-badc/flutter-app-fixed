// complaint_state.dart
import 'package:demo_app/data/models/pump_execution_request_type.dart';

abstract class PumpControlButtonState {}

class PumpControlButtonInitialState extends PumpControlButtonState {}

class PumpControlButtonLoadingState extends PumpControlButtonState {
  final int stationId;

  PumpControlButtonLoadingState({required this.stationId});
}

class PumpControlButtonSuccessState extends PumpControlButtonState {
  final int stationId;
  final PumpExecutionRequestType type;
  final DateTime requestTime;
  final bool isRunning;

  PumpControlButtonSuccessState({
    required this.stationId,
    required this.type,
    required this.requestTime,
    required this.isRunning,
  });
}

class PumpControlButtonFailureState extends PumpControlButtonState {
  final int stationId;
  final String errorMessage;

  PumpControlButtonFailureState({
    required this.stationId,
    required this.errorMessage,
  });
}
