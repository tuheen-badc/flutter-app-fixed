import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/water_budget_update_payload.dart';
import 'package:demo_app/domain/repository/water_budget.dart';
import 'package:demo_app/service_locator.dart';

class GetWaterBudgetUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<WaterBudgetRepository>().getWaterBudget(param!);
  }
}

class UpdateWaterBudgetUseCase
    implements UseCase<Either, WaterBudgetUpdatePayload> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<WaterBudgetRepository>().updateWaterBudget(param!);
  }
}
