// firmware_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../repository/firmware.dart';

class FirmwareHistoryUseCase implements UseCase<Either, void> {
  @override
  Future<Either> call({void param}) async {
    return serviceLocator<FirmwareRepository>().getFirmwareHistory();
  }
}
