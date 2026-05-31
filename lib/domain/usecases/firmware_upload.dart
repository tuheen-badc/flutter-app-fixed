// firmware_upload_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/firmware_upload_request.dart';
import 'package:demo_app/service_locator.dart';

import '../repository/firmware.dart';

class FirmwareUploadUseCase implements UseCase<Either, FirmwareUploadRequest> {
  @override
  Future<Either> call({FirmwareUploadRequest? param}) async {
    return serviceLocator<FirmwareRepository>().uploadFirmware(param!);
  }
}
