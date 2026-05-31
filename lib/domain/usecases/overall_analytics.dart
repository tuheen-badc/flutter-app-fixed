// overall_analytics_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../repository/analytics.dart';

class OverallAnalyticsUseCase implements UseCase<Either, void> {
  @override
  Future<Either> call({void param}) async {
    return serviceLocator<AnalyticsRepository>().getOverallAnalytics();
  }
}
