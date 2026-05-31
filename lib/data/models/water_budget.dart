class WaterBudget {
  final int id;
  final double totalLandArea;
  final double totalWater;

  WaterBudget({
    required this.id,
    required this.totalLandArea,
    required this.totalWater,
  });

  factory WaterBudget.fromJson(Map<String, dynamic> json) {
    return WaterBudget(
      id: json['id'] as int,
      totalLandArea: (json['totalLandArea'] as num).toDouble(),
      totalWater: (json['totalWater'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'totalLandArea': totalLandArea, 'totalWater': totalWater};
  }
}
