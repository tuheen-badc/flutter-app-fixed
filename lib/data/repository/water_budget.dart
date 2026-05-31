import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/water_budget.dart';
import 'package:demo_app/data/models/water_budget_update_payload.dart';
import 'package:demo_app/data/source/water_budget_api_service.dart';
import 'package:demo_app/domain/repository/water_budget.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

class WaterBudgetRepositoryImplementation extends WaterBudgetRepository {
  @override
  Future<Either> getWaterBudget(int pumpStationId) async {
    Either result = await serviceLocator<WaterBudgetApiService>()
        .getWaterBudget(pumpStationId);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(WaterBudget.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> updateWaterBudget(WaterBudgetUpdatePayload payload) async {
    Either result = await serviceLocator<WaterBudgetApiService>()
        .updateWaterBudget(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(WaterBudget.fromJson(response.data));
      },
    );
  }
}
