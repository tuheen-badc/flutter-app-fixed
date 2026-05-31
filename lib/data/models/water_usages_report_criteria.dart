// water_usage_report_criteria.dart
class WaterUsageReportCriteria {
  final int month;
  final int year;
  final int? officeId;
  final int? pumpHouseId;
  final int? userId;

  WaterUsageReportCriteria({
    required this.month,
    required this.year,
    this.officeId,
    this.pumpHouseId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'month': month, 'year': year};

    if (officeId != null) map['officeId'] = officeId;
    if (pumpHouseId != null) map['pumpHouseId'] = pumpHouseId;
    if (userId != null) map['userId'] = userId;

    return map;
  }
}
