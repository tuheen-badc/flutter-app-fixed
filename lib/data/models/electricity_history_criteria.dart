// electricity_history_criteria.dart

class ElectricityHistoryCriteria {
  final int pumpStationId;
  final int page;
  final int size;
  final DateTime? fromDate;
  final DateTime? toDate;

  ElectricityHistoryCriteria({
    required this.pumpStationId,
    this.page = 0,
    this.size = 20,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'size': size};

    if (fromDate != null) {
      map['fromDate'] = fromDate!.toUtc().toIso8601String();
    }
    if (toDate != null) {
      // Include the full end day by moving to end-of-day.
      final endOfDay = DateTime(
        toDate!.year,
        toDate!.month,
        toDate!.day,
        23,
        59,
        59,
      );
      map['toDate'] = endOfDay.toUtc().toIso8601String();
    }

    return map;
  }
}
