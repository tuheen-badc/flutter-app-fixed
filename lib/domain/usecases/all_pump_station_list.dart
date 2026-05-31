import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class AllPumpStationListUseCase
    implements UseCase<Either, PumpStationCriteria> {
  @override
  Future<Either> call({PumpStationCriteria? param}) async {
    return serviceLocator<PumpStationRepository>().allPumpStationList(param!);
  }
}
