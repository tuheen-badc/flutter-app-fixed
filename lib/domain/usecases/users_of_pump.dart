import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/user_of_pump_station.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class UsersOfPumpUseCase implements UseCase<Either, UserOfPumpStationParam> {
  @override
  Future<Either> call({UserOfPumpStationParam? param}) async {
    return serviceLocator<PumpStationRepository>().userOfPumpStation(param!);
  }
}
