import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/pump_execution_payload.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pump_station_creation_payload.dart';
import '../models/pump_station_update_payload.dart';
import '../models/single_pump_station_history_criteria.dart';
import '../models/user_of_pump_station.dart';

abstract class PumpStationApiService {
  Future<Either> pumpExecutionRequest(PumpExecutionPayload payload);

  Future<Either> pumpStationBasicList();

  Future<Either> allPumpStationList(PumpStationCriteria criteria);

  Future<Either> singlePumpStationHistory(SinglePumpStationHistoryParam param);

  Future<Either> getPumpStationById(int pumpStationId);

  Future<Either> userOfPumpStation(UserOfPumpStationParam param);

  Future<Either> createPumpStation(PumpStationCreationPayload payload);

  Future<Either> getPumpLiveStatus(int userId);

  Future<Either> updatePumpLocation(UpdatePumpLocationPayload payload);

  Future<Either> updateManagerPhone(UpdateManagerPhonePayload payload);

  Future<Either> updateDataProviderPhone(
    UpdateDataProviderPhonePayload payload,
  );
}

class PumpStationApiServiceImplementation extends PumpStationApiService {
  @override
  Future<Either> pumpExecutionRequest(PumpExecutionPayload payload) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.pumpExecutionRequest(payload.pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> pumpStationBasicList() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.pumpStationBasicList,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.company.pumpstation.basic+json',
          },
        ),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> allPumpStationList(PumpStationCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.allPumpStationList,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> singlePumpStationHistory(
    SinglePumpStationHistoryParam param,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.singlePumpStationHistory(param.pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> getPumpStationById(int pumpStationId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final response = await serviceLocator<DioClient>().get(
        ApiUrls.pumpDetailById(pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<Either> updatePumpLocation(UpdatePumpLocationPayload payload) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final response = await serviceLocator<DioClient>().patch(
        ApiUrls.updatePumpLocation(payload.pumpStationId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/update-location+json',
        ),
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  // ── PATCH /pumpStations/{id}/manager-phone ───────────────────────────────────
  @override
  Future<Either> updateManagerPhone(UpdateManagerPhonePayload payload) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final response = await serviceLocator<DioClient>().patch(
        ApiUrls.updateManagerPhone(payload.pumpStationId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/update-manager+json',
        ),
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  // ── PATCH /pumpStations/{id}/data-provider-phone ─────────────────────────────
  @override
  Future<Either> updateDataProviderPhone(
    UpdateDataProviderPhonePayload payload,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      final response = await serviceLocator<DioClient>().patch(
        ApiUrls.updateDataProviderPhone(payload.pumpStationId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/update-data-provider+json',
        ),
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<Either> userOfPumpStation(UserOfPumpStationParam param) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userOfPumpStation(param.pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> getPumpLiveStatus(int userId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');
      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.pumpLiveStatus(userId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> createPumpStation(PumpStationCreationPayload payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final Response response = await serviceLocator<DioClient>().post(
        ApiUrls.createPumpStation,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }
}
