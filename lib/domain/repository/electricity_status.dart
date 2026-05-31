import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/electricity_status_criteria.dart';

import '../../data/models/electricity_history_criteria.dart';

abstract class ElectricityStatusRepository {
  Future<Either> getElectricityStatus(ElectricityStatusCriteria criteria);
  Future<Either> electricityStatusHistory(ElectricityHistoryCriteria criteria);
}
