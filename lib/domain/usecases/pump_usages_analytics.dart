// user_analytics_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/analytics.dart';
import 'package:demo_app/service_locator.dart';

class UserSpecificAnalyticsUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<AnalyticsRepository>().getUserSpecificAnalytics(
      param!,
    );
  }
}
