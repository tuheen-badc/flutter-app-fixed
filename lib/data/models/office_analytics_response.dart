// data/models/office_analytics_response.dart
class OfficeAnalyticsResponse {
  final double suppliedVolume;
  final double deductedAmount;
  final int totalUser;
  final int totalAdmin;
  final int totalPump;
  final double totalOperatedHours;
  final int totalRunningPump;
  final double totalDebitAmount;

  OfficeAnalyticsResponse({
    required this.suppliedVolume,
    required this.deductedAmount,
    required this.totalUser,
    required this.totalAdmin,
    required this.totalPump,
    required this.totalOperatedHours,
    required this.totalRunningPump,
    required this.totalDebitAmount,
  });

  factory OfficeAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return OfficeAnalyticsResponse(
      suppliedVolume: (json['suppliedVolume'] ?? 0).toDouble(),
      deductedAmount: (json['deductedAmount'] ?? 0).toDouble(),
      totalUser: (json['totalUser'] ?? 0).toInt(),
      totalAdmin: (json['totalAdmin'] ?? 0).toInt(),
      totalPump: (json['totalPump'] ?? 0).toInt(),
      totalOperatedHours: (json['totalOperatedHours'] ?? 0).toDouble(),
      totalRunningPump: (json['totalRunningPump'] ?? 0).toInt(),
      totalDebitAmount: (json['totalDebitAmount'] ?? 0).toDouble(),
    );
  }
}
