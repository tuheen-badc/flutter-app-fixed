// analytics_response.dart
class AnalyticsResponse {
  final int totalPump;
  final int runningPump;
  final int totalUser;

  AnalyticsResponse({
    required this.totalPump,
    required this.runningPump,
    required this.totalUser,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      totalPump: json['totalPump'] ?? 0,
      runningPump: json['runningPump'] ?? 0,
      totalUser: json['totalUser'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPump': totalPump,
      'runningPump': runningPump,
      'totalUser': totalUser,
    };
  }

  // Calculated properties
  int get stoppedPump => totalPump - runningPump;

  double get runningPercentage =>
      totalPump > 0 ? (runningPump / totalPump) * 100 : 0;

  double get stoppedPercentage =>
      totalPump > 0 ? (stoppedPump / totalPump) * 100 : 0;
}
