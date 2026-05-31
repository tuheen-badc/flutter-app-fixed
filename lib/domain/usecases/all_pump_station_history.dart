import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class AllPumpStationHistoryUseCase
    implements UseCase<Either, PumpStationHistoryParam> {
  @override
  Future<Either> call({PumpStationHistoryParam? param}) async {
    return serviceLocator<UserRepository>().allPumpStationHistory(param!);
  }
}
