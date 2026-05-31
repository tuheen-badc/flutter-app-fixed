import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/water_budget_update_payload.dart';

abstract class WaterBudgetRepository {
  Future<Either> getWaterBudget(int pumpStationId);

  Future<Either> updateWaterBudget(WaterBudgetUpdatePayload payload);
}
