// user_analytics_response.dart
import 'package:demo_app/data/models/usages_analytics.dart';

import 'transaction_summary.dart';

class UserAnalyticsResponse {
  final TransactionSummary transactionSummary;
  final List<UsageAnalytics> usagesAnalytics;

  UserAnalyticsResponse({
    required this.transactionSummary,
    required this.usagesAnalytics,
  });

  factory UserAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsResponse(
      transactionSummary: TransactionSummary.fromJson(
        json['transactionSummary'] as Map<String, dynamic>,
      ),
      usagesAnalytics: (json['usagesAnalytics'] as List)
          .map((item) => UsageAnalytics.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
