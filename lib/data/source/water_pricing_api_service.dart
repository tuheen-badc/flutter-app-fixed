import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_pricing_update_request.dart';

abstract class WaterPricingApiService {
  Future<Either> getWaterPricing();

  Future<Either> updateWaterPricing(WaterPricingRequest request);
}

class WaterPricingApiServiceImplementation extends WaterPricingApiService {
  @override
  Future<Either> getWaterPricing() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.waterPricing,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updateWaterPricing(WaterPricingRequest request) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.updateWaterPricing,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: request.toJson(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to update pricing');
    }
  }
}
