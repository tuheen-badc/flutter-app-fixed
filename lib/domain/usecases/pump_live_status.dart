// pump_live_status_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class PumpLiveStatusUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<PumpStationRepository>().getPumpLiveStatus(param!);
  }
}
