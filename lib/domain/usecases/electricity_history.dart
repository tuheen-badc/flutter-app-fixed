// electricity_history_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/electricity_history_criteria.dart';
import 'package:demo_app/domain/repository/electricity_status.dart';
import 'package:demo_app/service_locator.dart';

class ElectricityHistoryUseCase
    implements UseCase<Either, ElectricityHistoryCriteria> {
  @override
  Future<Either> call({ElectricityHistoryCriteria? param}) async {
    return serviceLocator<ElectricityStatusRepository>()
        .electricityStatusHistory(param!);
  }
}
