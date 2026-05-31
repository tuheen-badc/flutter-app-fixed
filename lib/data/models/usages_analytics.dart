// usage_analytics.dart
class UsageAnalytics {
  final int year;
  final int month;
  final double totalUsages;

  UsageAnalytics({
    required this.year,
    required this.month,
    required this.totalUsages,
  });

  factory UsageAnalytics.fromJson(Map<String, dynamic> json) {
    return UsageAnalytics(
      year: json['year'] as int,
      month: json['month'] as int,
      totalUsages: (json['totalUsages'] as num).toDouble(),
    );
  }

  // Helper to get month name
  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Helper for chart label (e.g., "Jan 25")
  String get chartLabel => '$monthName ${year.toString().substring(2)}';
}
