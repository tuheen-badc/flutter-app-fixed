// pump_station.dart
import 'package:demo_app/data/models/pump_execution_request_type.dart';

class PumpStationResponse {
  final List<PumpStationItem> stationList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PumpStationResponse({
    required this.stationList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PumpStationResponse.fromJson(Map<String, dynamic> json) {
    return PumpStationResponse(
      stationList: (json['_embedded']['pumpStationDtoList'] as List)
          .map((item) => PumpStationItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class PumpStationItem {
  final int id;
  final String name;
  final String divisionName;
  final String districtName;
  final String upazillaName;
  final String unionName;
  final bool running;
  final DateTime? startedAt;
  final DateTime? requestedAt;
  final PumpExecutionRequestType? pendingRequestType;

  PumpStationItem({
    required this.id,
    required this.name,
    required this.divisionName,
    required this.districtName,
    required this.upazillaName,
    required this.unionName,
    required this.running,
    this.startedAt,
    this.requestedAt,
    this.pendingRequestType,
  });

  factory PumpStationItem.fromJson(Map<String, dynamic> json) {
    return PumpStationItem(
      id: json['id'],
      name: json['name'],
      divisionName: json['divisionName'] ?? '',
      districtName: json['districtName'] ?? '',
      upazillaName: json['upazillaName'] ?? '',
      unionName: json['unionName'] ?? '',
      running: json['running'],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : null,
      pendingRequestType: json['pendingRequestType'] != null
          ? PumpExecutionRequestType.values.byName(
              json['pendingRequestType'] as String,
            )
          : null,
    );
  }

  PumpStationItem copyWith({
    int? id,
    String? name,
    String? divisionName,
    String? districtName,
    String? upazillaName,
    String? unionName,
    bool? running,
    DateTime? startedAt,
  }) {
    return PumpStationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      divisionName: divisionName ?? this.divisionName,
      districtName: districtName ?? this.districtName,
      upazillaName: upazillaName ?? this.upazillaName,
      unionName: unionName ?? this.unionName,
      running: running ?? this.running,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
