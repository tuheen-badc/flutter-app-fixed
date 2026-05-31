import 'package:dartz/dartz.dart';
import 'package:demo_app/data/source/analytics_api_service.dart';
import 'package:demo_app/domain/repository/analytics.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/AnalyticsResponse.dart';
import '../models/office_analytics_response.dart';
import '../models/pump_analytics_response.dart';
import '../models/user_specific_analytics.dart';

class AnalyticsRepositoryImplementation extends AnalyticsRepository {
  @override
  Future<Either> getUserSpecificAnalytics(int userId) async {
    Either result = await serviceLocator<AnalyticsApiService>()
        .getUserSpecificAnalytics(userId);

    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(UserAnalyticsResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> getOverallAnalytics() async {
    Either result = await serviceLocator<AnalyticsApiService>()
        .getOverallAnalytics();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(AnalyticsResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> getOfficeAnalytics(int officeId) async {
    final Either result = await serviceLocator<AnalyticsApiService>()
        .getOfficeAnalytics(officeId);
    return result.fold(
          (error) => Left(error),
          (data) => Right(OfficeAnalyticsResponse.fromJson((data as Response).data)),
    );
  }

  @override
  Future<Either> getPumpAnalytics(int pumpStationId) async {
    final Either result = await serviceLocator<AnalyticsApiService>()
        .getPumpAnalytics(pumpStationId);
    return result.fold(
          (error) => Left(error),
          (data) =>
          Right(PumpAnalyticsResponse.fromJson((data as Response).data)),
    );
  }
}
