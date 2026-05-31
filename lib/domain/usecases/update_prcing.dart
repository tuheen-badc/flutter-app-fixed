// update_water_pricing_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/water_pricing_update_request.dart';
import '../repository/water_pricing.dart';

class UpdateWaterPricingUseCase
    implements UseCase<Either, WaterPricingRequest> {
  @override
  Future<Either> call({WaterPricingRequest? param}) async {
    return serviceLocator<WaterPricingRepository>().updateWaterPricing(param!);
  }
}
