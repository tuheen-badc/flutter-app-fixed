import 'package:decimal/decimal.dart';

class UsagesAnalytics {
  final int year;
  final int month;
  final Decimal total;

  UsagesAnalytics({
    required this.year,
    required this.month,
    required this.total,
  });

  factory UsagesAnalytics.fromJson(Map<String, dynamic> json) {
    return UsagesAnalytics(
      year: json['year'] as int,
      month: json['month'] as int,
      total: Decimal.parse(json['total'].toString()),
    );
  }
}
