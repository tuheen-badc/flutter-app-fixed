// firmware_repository.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/firmware_upload_request.dart';

abstract class FirmwareRepository {
  Future<Either> uploadFirmware(FirmwareUploadRequest request);

  Future<Either> getFirmwareHistory();
}
