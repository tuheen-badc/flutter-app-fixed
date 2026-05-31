import 'package:demo_app/data/models/pump_execution_request_type.dart';

class PumpExecutionPayload {
  final int pumpStationId;
  final PumpExecutionRequestType type;

  PumpExecutionPayload({required this.pumpStationId, required this.type});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'type': type.name.toUpperCase()};
    return map;
  }
}
