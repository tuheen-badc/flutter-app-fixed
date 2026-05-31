// domain/usecases/office_analytics_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/analytics.dart';
import 'package:demo_app/service_locator.dart';

class OfficeAnalyticsUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<AnalyticsRepository>().getOfficeAnalytics(
      param!,
    );
  }
}
