import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/water_usages_report_criteria.dart';
import '../repository/water_usages_report.dart';

class DownloadWaterUsageReportUseCase
    implements UseCase<Either, WaterUsageReportCriteria> {
  @override
  Future<Either> call({WaterUsageReportCriteria? param}) async {
    return serviceLocator<WaterUsageReportRepository>()
        .downloadWaterUsageReport(param!);
  }
}
