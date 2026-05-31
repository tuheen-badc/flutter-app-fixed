class PumpStationHistoryParam {
  final int page;
  final int size;
  final String? userPhone;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? divisionId;
  final int? districtId;
  final int? upazillaId;
  final int? unionId;
  final int? pumpStationId;
  final int? userId;

  PumpStationHistoryParam({
    required this.page,
    required this.size,
    this.userPhone,
    this.fromDate,
    this.toDate,
    this.divisionId,
    this.districtId,
    this.upazillaId,
    this.unionId,
    this.pumpStationId,
    this.userId
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'page': page, 'size': size};

    if (userPhone != null && userPhone!.isNotEmpty) {
      json['userPhone'] = userPhone;
    }
    if (fromDate != null) {
      json['fromDate'] = fromDate!.toUtc().toIso8601String();
    }
    if (toDate != null) {
      json['toDate'] = toDate!.toUtc().toIso8601String();
    }
    if (divisionId != null) {
      json['divisionId'] = divisionId;
    }
    if (districtId != null) {
      json['districtId'] = districtId;
    }
    if (upazillaId != null) {
      json['upazillaId'] = upazillaId;
    }
    if (unionId != null) {
      json['unionId'] = unionId;
    }
    if (pumpStationId != null) {
      json['pumpStationId'] = pumpStationId;
    }

    return json;
  }
}
