// data/models/pump_station_creation_payload.dart

class PumpStationCreationPayload {
  final int divisionId;
  final int districtId;
  final int? upazillaId;
  final int? unionId;
  final int officeId;
  final String? managerPhone;
  final String dataProviderPhone;

  const PumpStationCreationPayload({
    required this.divisionId,
    required this.districtId,
    this.upazillaId,
    this.unionId,
    required this.officeId,
    this.managerPhone,
    required this.dataProviderPhone,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'divisionId': divisionId,
      'districtId': districtId,
      'officeId': officeId,
      'dataProviderPhone': dataProviderPhone,
    };
    if (upazillaId != null) map['upazillaId'] = upazillaId;
    if (unionId != null) map['unionId'] = unionId;
    if (managerPhone != null && managerPhone!.isNotEmpty) {
      map['managerPhone'] = managerPhone;
    }
    return map;
  }
}

class PumpStationCreationResponse {
  final int id;
  final String name;

  const PumpStationCreationResponse({required this.id, required this.name});

  factory PumpStationCreationResponse.fromJson(Map<String, dynamic> json) {
    return PumpStationCreationResponse(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
