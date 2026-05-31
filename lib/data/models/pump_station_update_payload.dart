// data/models/pump_station_update_payloads.dart

// ── Location update ───────────────────────────────────────────────────────────

class UpdatePumpLocationPayload {
  final int pumpStationId;
  final int divisionId;
  final int districtId;
  final int? upazillaId;
  final int? unionId;

  const UpdatePumpLocationPayload({
    required this.pumpStationId,
    required this.divisionId,
    required this.districtId,
    this.upazillaId,
    this.unionId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'divisionId': divisionId,
      'districtId': districtId,
    };
    if (upazillaId != null) map['upazillaId'] = upazillaId;
    if (unionId != null) map['unionId'] = unionId;
    return map;
  }
}

// ── Manager phone update ──────────────────────────────────────────────────────

class UpdateManagerPhonePayload {
  final int pumpStationId;
  final String managerPhone;

  const UpdateManagerPhonePayload({
    required this.pumpStationId,
    required this.managerPhone,
  });

  Map<String, dynamic> toMap() => {'managerPhone': managerPhone};
}

// ── Data provider phone update ────────────────────────────────────────────────

class UpdateDataProviderPhonePayload {
  final int pumpStationId;
  final String dataProviderPhone;

  const UpdateDataProviderPhonePayload({
    required this.pumpStationId,
    required this.dataProviderPhone,
  });

  Map<String, dynamic> toMap() => {'dataProviderPhone': dataProviderPhone};
}
