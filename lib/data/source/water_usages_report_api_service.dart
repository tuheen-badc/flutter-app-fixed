import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_usages_report_criteria.dart';

abstract class WaterUsageReportApiService {
  Future<Either> downloadWaterUsageReport(WaterUsageReportCriteria criteria);
}

class WaterUsageReportApiServiceImplementation
    extends WaterUsageReportApiService {
  @override
  Future<Either> downloadWaterUsageReport(
    WaterUsageReportCriteria criteria,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.waterUsageReportDownload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes, // Important: receive as bytes
        ),
        queryParameters: criteria
            .toMap(), // Send as query params (Spring Boot binds without @RequestBody)
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? 'Download failed');
    }
  }
}
