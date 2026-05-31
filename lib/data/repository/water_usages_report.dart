import 'package:dartz/dartz.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../../domain/repository/water_usages_report.dart';
import '../models/water_usages_report_criteria.dart';
import '../source/water_usages_report_api_service.dart';

class WaterUsageReportRepositoryImplementation
    extends WaterUsageReportRepository {
  @override
  Future<Either> downloadWaterUsageReport(
    WaterUsageReportCriteria criteria,
  ) async {
    Either result = await serviceLocator<WaterUsageReportApiService>()
        .downloadWaterUsageReport(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response.data); // Return the bytes directly
      },
    );
  }
}
