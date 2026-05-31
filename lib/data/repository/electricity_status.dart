import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/electricity_status_criteria.dart';
import 'package:demo_app/data/source/electricity_status_api_service.dart';
import 'package:demo_app/domain/repository/electricity_status.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/electricity_history.dart';
import '../models/electricity_history_criteria.dart';
import '../models/electricity_status.dart';

class ElectricityStatusRepositoryImplementation
    extends ElectricityStatusRepository {
  @override
  Future<Either> getElectricityStatus(
    ElectricityStatusCriteria criteria,
  ) async {
    Either result = await serviceLocator<ElectricityStatusApiService>()
        .getAllElectricityStatus(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(ElectricityAvailabilityResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> electricityStatusHistory(
    ElectricityHistoryCriteria criteria,
  ) async {
    Either result = await serviceLocator<ElectricityStatusApiService>()
        .electricityStatusHistory(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(ElectricityStatusHistoryResponse.fromJson(response.data));
      },
    );
  }
}
