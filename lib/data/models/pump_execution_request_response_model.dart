import 'package:demo_app/data/models/pump_execution_request_type.dart';

class PumpExecutionRequestResponseModel {
  final DateTime requestTime;
  final PumpExecutionRequestType type;

  PumpExecutionRequestResponseModel({
    required this.requestTime,
    required this.type,
  });

  factory PumpExecutionRequestResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PumpExecutionRequestResponseModel(
      requestTime: DateTime.parse(json['requestTime'] as String),
      type: PumpExecutionRequestType.values.byName(json['type'] as String),
    );
  }
}
