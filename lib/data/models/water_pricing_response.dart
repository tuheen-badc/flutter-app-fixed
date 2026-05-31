class WaterPricingResponse {
  final double tierOneRate;
  final double tierTwoRate;
  final double tierThreeRate;

  WaterPricingResponse({
    required this.tierOneRate,
    required this.tierTwoRate,
    required this.tierThreeRate,
  });

  factory WaterPricingResponse.fromJson(Map<String, dynamic> json) {
    return WaterPricingResponse(
      tierOneRate: (json['tierOneRate'] as num).toDouble(),
      tierTwoRate: (json['tierTwoRate'] as num).toDouble(),
      tierThreeRate: (json['tierThreeRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tierOneRate': tierOneRate,
      'tierTwoRate': tierTwoRate,
      'tierThreeRate': tierThreeRate,
    };
  }
}
