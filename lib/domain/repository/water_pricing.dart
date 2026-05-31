import 'package:dartz/dartz.dart';

import '../../data/models/water_pricing_update_request.dart';

abstract class WaterPricingRepository {
  Future<Either> getWaterPricing();

  Future<Either> updateWaterPricing(WaterPricingRequest request);
}
