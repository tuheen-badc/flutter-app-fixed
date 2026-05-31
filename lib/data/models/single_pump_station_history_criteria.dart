class SinglePumpStationHistoryParam {
  final int page;
  final int size;
  final String? userPhone;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int pumpStationId;

  SinglePumpStationHistoryParam({
    required this.page,
    required this.size,
    this.userPhone,
    this.fromDate,
    this.toDate,
    required this.pumpStationId,
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
    return json;
  }
}
