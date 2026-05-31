class TransactionHistoryParams {
  final int page;
  final int size;
  final DateTime? fromDate;
  final DateTime? toDate;
  int? userId;

  TransactionHistoryParams({
    this.page = 0,
    this.size = 20,
    this.fromDate,
    this.toDate,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'size': size};

    if (fromDate != null) {
      map['fromDate'] = fromDate!.toUtc().toIso8601String();
    }

    if (toDate != null) {
      map['toDate'] = toDate!.toUtc().toIso8601String();
    }

    return map;
  }
}
