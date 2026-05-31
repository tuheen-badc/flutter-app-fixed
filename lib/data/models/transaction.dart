class TransactionHistoryItem {
  final double amount;
  final DateTime transactionTime;
  final String? medium;
  final String direction; // "CREDIT" or "DEBIT"
  final int? creditReference;

  TransactionHistoryItem({
    required this.amount,
    required this.transactionTime,
    this.medium,
    required this.direction,
    this.creditReference,
  });

  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryItem(
      amount: (json['amount'] as num).toDouble(),
      transactionTime: DateTime.parse(json['transactionTime']),
      medium: json['medium'] as String?,
      direction: json['direction'] as String,
      creditReference: json['creditReference'] as int?,
    );
  }

  bool get isCredit => direction.toUpperCase() == 'CREDIT';

  String get displayMedium {
    if (medium == null || medium!.isEmpty) {
      return 'N/A';
    }
    return medium!;
  }
}
