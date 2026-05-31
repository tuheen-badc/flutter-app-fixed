import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/pump_execution_payload.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class PumpStationExecutionUseCase
    implements UseCase<Either, PumpExecutionPayload> {
  @override
  Future<Either> call({PumpExecutionPayload? param}) async {
    return serviceLocator<PumpStationRepository>().pumpExecutionRequest(param!);
  }
}
