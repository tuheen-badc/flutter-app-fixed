// water_pricing_request.dart
class WaterPricingRequest {
  final double tierOneRate;
  final double tierTwoRate;
  final double tierThreeRate;

  WaterPricingRequest({
    required this.tierOneRate,
    required this.tierTwoRate,
    required this.tierThreeRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'tierOneRate': tierOneRate,
      'tierTwoRate': tierTwoRate,
      'tierThreeRate': tierThreeRate,
    };
  }
}
