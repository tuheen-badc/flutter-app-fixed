// transaction_summary.dart
class TransactionSummary {
  final double totalDebit;
  final double totalCredit;

  TransactionSummary({required this.totalDebit, required this.totalCredit});

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
    );
  }

  double get balance => totalCredit - totalDebit;

  bool get hasPositiveBalance => balance >= 0;
}
