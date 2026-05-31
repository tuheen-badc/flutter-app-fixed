// firmware_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/firmware_history_item.dart';
import 'package:demo_app/data/models/firmware_upload_request.dart';
import 'package:demo_app/data/source/firmware_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../../domain/repository/firmware.dart';

class FirmwareRepositoryImplementation extends FirmwareRepository {
  @override
  Future<Either> uploadFirmware(FirmwareUploadRequest request) async {
    Either result = await serviceLocator<FirmwareApiService>().uploadFirmware(
      request,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response.data);
      },
    );
  }

  @override
  Future<Either> getFirmwareHistory() async {
    Either result = await serviceLocator<FirmwareApiService>()
        .getFirmwareHistory();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(FirmwareHistoryResponse.fromJson(response.data));
      },
    );
  }
}
