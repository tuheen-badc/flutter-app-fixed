import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/water_budget_update_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class WaterBudgetApiService {
  Future<Either> getWaterBudget(int pumpStationId);

  Future<Either> updateWaterBudget(WaterBudgetUpdatePayload payload);
}

class WaterBudgetApiServiceImplementation extends WaterBudgetApiService {
  @override
  Future<Either> getWaterBudget(int pumpStationId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.getWaterBudget(pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updateWaterBudget(WaterBudgetUpdatePayload payload) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().put(
        ApiUrls.updateWaterBudget(payload.id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
