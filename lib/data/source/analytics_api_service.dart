import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AnalyticsApiService {
  Future<Either> getUserSpecificAnalytics(int userId);

  Future<Either> getOverallAnalytics();

  Future<Either> getOfficeAnalytics(int officeId);

  Future<Either> getPumpAnalytics(int pumpStationId);
}

class AnalyticsServiceImplementation extends AnalyticsApiService {
  @override
  Future<Either> getUserSpecificAnalytics(int userId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userSpecificAnalytics(userId),
        queryParameters: {'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to load analytics');
    }
  }

  @override
  Future<Either> getOverallAnalytics() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.overallAnalytics,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<Either> getOfficeAnalytics(int officeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await serviceLocator<DioClient>().get(
        ApiUrls.officeAnalytics(officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<Either> getPumpAnalytics(int pumpStationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await serviceLocator<DioClient>().get(
        ApiUrls.pumpAnalytics(pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'An error occurred');
    }
  }
}
