// domain/usecases/create_pump_station_use_cases.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_station_creation_payload.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class CreatePumpStationUseCase
    implements UseCase<Either, PumpStationCreationPayload> {
  @override
  Future<Either> call({PumpStationCreationPayload? param}) async {
    return serviceLocator<PumpStationRepository>().createPumpStation(param!);
  }
}
