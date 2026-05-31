class WaterBudgetUpdatePayload {
  final int id;
  final double totalLandArea;
  final double totalWater;

  WaterBudgetUpdatePayload({
    required this.id,
    required this.totalLandArea,
    required this.totalWater,
  });

  Map<String, dynamic> toJson() {
    return {'totalLandArea': totalLandArea, 'totalWater': totalWater};
  }
}
