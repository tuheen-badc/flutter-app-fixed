import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/water_pricing.dart';
import 'package:demo_app/service_locator.dart';

class WaterPricingUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<WaterPricingRepository>().getWaterPricing();
  }
}
