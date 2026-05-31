import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/electricity_status_criteria.dart';
import 'package:demo_app/domain/repository/electricity_status.dart';
import 'package:demo_app/service_locator.dart';

class ElectricityStatusUseCase
    implements UseCase<Either, ElectricityStatusCriteria> {
  @override
  Future<Either> call({ElectricityStatusCriteria? param}) async {
    return serviceLocator<ElectricityStatusRepository>().getElectricityStatus(
      param!,
    );
  }
}
