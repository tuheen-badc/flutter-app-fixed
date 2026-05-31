// data/models/pump_analytics_response.dart
class PumpAnalyticsResponse {
  final double totalOperatedHours;
  final double suppliedVolume;
  final double deductedAmount;

  PumpAnalyticsResponse({
    required this.totalOperatedHours,
    required this.suppliedVolume,
    required this.deductedAmount,
  });

  factory PumpAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return PumpAnalyticsResponse(
      totalOperatedHours: (json['totalOperatedHours'] ?? 0).toDouble(),
      suppliedVolume: (json['suppliedVolume'] ?? 0).toDouble(),
      deductedAmount: (json['deductedAmount'] ?? 0).toDouble(),
    );
  }
}
