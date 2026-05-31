// firmware_api_service.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/firmware_upload_request.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FirmwareApiService {
  Future<Either> uploadFirmware(FirmwareUploadRequest request);

  Future<Either> getFirmwareHistory();
}

class FirmwareApiServiceImplementation extends FirmwareApiService {
  @override
  Future<Either> uploadFirmware(FirmwareUploadRequest request) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      // Create FormData
      FormData formData = FormData.fromMap({
        'version': request.version,
        'file': await MultipartFile.fromFile(
          request.file.path,
          filename: request.file.path.split('/').last,
        ),
      });

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.firmwareUpload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: formData,
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Upload failed');
    }
  }

  @override
  Future<Either> getFirmwareHistory() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.firmwareHistory,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to load history');
    }
  }
}
