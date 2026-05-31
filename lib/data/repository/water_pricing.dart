import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/water_pricing_response.dart';
import 'package:demo_app/data/source/water_pricing_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../../domain/repository/water_pricing.dart';
import '../models/water_pricing_update_request.dart';

class WaterPricingRepositoryImplementation extends WaterPricingRepository {
  @override
  Future<Either> getWaterPricing() async {
    Either result = await serviceLocator<WaterPricingApiService>()
        .getWaterPricing();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(WaterPricingResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> updateWaterPricing(WaterPricingRequest request) async {
    Either result = await serviceLocator<WaterPricingApiService>()
        .updateWaterPricing(request);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response.data);
      },
    );
  }
}
