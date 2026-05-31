import 'package:dartz/dartz.dart';

abstract class AnalyticsRepository {
  Future<Either> getOverallAnalytics();

  Future<Either> getUserSpecificAnalytics(int userId);

  Future<Either> getOfficeAnalytics(int officeId);

  Future<Either> getPumpAnalytics(int pumpStationId);
}
