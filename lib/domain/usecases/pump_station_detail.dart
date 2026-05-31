// domain/usecases/pump_detail_use_cases.dart
//
// Four use cases in one file for convenience. Split into separate files if
// your project convention requires it.

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/pump_station_update_payload.dart';

// ── 1. Get pump station detail view ──────────────────────────────────────────

class GetPumpStationDetailViewUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<PumpStationRepository>().getPumpStationById(param!);
  }
}

// ── 2. Update pump location ───────────────────────────────────────────────────

class UpdatePumpLocationUseCase
    implements UseCase<Either, UpdatePumpLocationPayload> {
  @override
  Future<Either> call({UpdatePumpLocationPayload? param}) async {
    return serviceLocator<PumpStationRepository>().updatePumpLocation(param!);
  }
}

// ── 3. Update manager phone ───────────────────────────────────────────────────

class UpdateManagerPhoneUseCase
    implements UseCase<Either, UpdateManagerPhonePayload> {
  @override
  Future<Either> call({UpdateManagerPhonePayload? param}) async {
    return serviceLocator<PumpStationRepository>().updateManagerPhone(param!);
  }
}

// ── 4. Update data provider phone ────────────────────────────────────────────

class UpdateDataProviderPhoneUseCase
    implements UseCase<Either, UpdateDataProviderPhonePayload> {
  @override
  Future<Either> call({UpdateDataProviderPhonePayload? param}) async {
    return serviceLocator<PumpStationRepository>().updateDataProviderPhone(
      param!,
    );
  }
}
