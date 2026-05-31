import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/single_pump_station_history_criteria.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

class SinglePumpStationHistoryUseCase
    implements UseCase<Either, SinglePumpStationHistoryParam> {
  @override
  Future<Either> call({SinglePumpStationHistoryParam? param}) async {
    return serviceLocator<PumpStationRepository>().singlePumpStationHistory(
      param!,
    );
  }
}
