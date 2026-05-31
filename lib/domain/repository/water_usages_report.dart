import 'package:dartz/dartz.dart';

import '../../data/models/water_usages_report_criteria.dart';

abstract class WaterUsageReportRepository {
  Future<Either> downloadWaterUsageReport(WaterUsageReportCriteria criteria);
}
