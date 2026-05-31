// pump_station_criteria.dart
class PumpStationCriteria {
  final int page;
  final int size;
  final int? divisionId;
  final int? districtId;
  final int? upazillaId;
  final int? unionId;
  final int? userId;

  PumpStationCriteria({
    this.page = 0,
    this.size = 20,
    this.divisionId,
    this.districtId,
    this.upazillaId,
    this.unionId,
    this.userId
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'size': size};

    if (divisionId != null) map['divisionId'] = divisionId;
    if (districtId != null) map['districtId'] = districtId;
    if (upazillaId != null) map['upazillaId'] = upazillaId;
    if (unionId != null) map['unionId'] = unionId;

    return map;
  }
}
