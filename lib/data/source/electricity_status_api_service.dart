import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/electricity_status_criteria.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/electricity_history_criteria.dart';

abstract class ElectricityStatusApiService {
  Future<Either> getAllElectricityStatus(ElectricityStatusCriteria criteria);

  Future<Either> electricityStatusHistory(ElectricityHistoryCriteria criteria);
}

class ElectricityStatusServiceImplementation
    extends ElectricityStatusApiService {
  @override
  Future<Either> getAllElectricityStatus(
    ElectricityStatusCriteria criteria,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.electricityAvailabilityIndicators,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> electricityStatusHistory(
    ElectricityHistoryCriteria criteria,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.electricityStatusHistory(criteria.pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
