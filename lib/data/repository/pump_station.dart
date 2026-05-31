import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/pump_execution_request_response_model.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/data/models/pump_station_basic_list.dart';
import 'package:demo_app/data/models/pump_station_detail.dart';
import 'package:demo_app/data/models/single_pump_station_history_criteria.dart';
import 'package:demo_app/data/models/user_of_pump_station.dart';
import 'package:demo_app/data/models/user_of_pump_station_response.dart';
import 'package:demo_app/data/source/pump_station_api_service.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/pump_execution_payload.dart';
import '../models/pump_live_status_model.dart';
import '../models/pump_station_creation_payload.dart';
import '../models/pump_station_histories.dart';
import '../models/pump_station_list.dart';
import '../models/pump_station_update_payload.dart';

class PumpStationRepositoryImplementation extends PumpStationRepository {
  @override
  Future<Either> pumpExecutionRequest(PumpExecutionPayload payload) async {
    Either result = await serviceLocator<PumpStationApiService>()
        .pumpExecutionRequest(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpExecutionRequestResponseModel.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> pumpStationBasicList() async {
    Either result = await serviceLocator<PumpStationApiService>()
        .pumpStationBasicList();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        List<dynamic> jsonData = response.data;
        List<PumpStationBasicDto> pumpStationBasicDtos = jsonData
            .map((row) => PumpStationBasicDto.fromJson(row))
            .toList();
        return Right(pumpStationBasicDtos);
      },
    );
  }

  @override
  Future<Either> allPumpStationList(PumpStationCriteria criteria) async {
    Either result = await serviceLocator<PumpStationApiService>()
        .allPumpStationList(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpStationResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> singlePumpStationHistory(
    SinglePumpStationHistoryParam param,
  ) async {
    Either result = await serviceLocator<PumpStationApiService>()
        .singlePumpStationHistory(param);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpStationHistoryResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> getPumpStationById(int pumpStationId) async {
    final Either result = await serviceLocator<PumpStationApiService>()
        .getPumpStationById(pumpStationId);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(
        PumpStationDetailView.fromJson(response.data as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<Either> updatePumpLocation(UpdatePumpLocationPayload payload) async {
    final Either result = await serviceLocator<PumpStationApiService>()
        .updatePumpLocation(payload);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(
        PumpStationDetailView.fromJson(response.data as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<Either> updateManagerPhone(UpdateManagerPhonePayload payload) async {
    final Either result = await serviceLocator<PumpStationApiService>()
        .updateManagerPhone(payload);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(
        PumpStationDetailView.fromJson(response.data as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<Either> updateDataProviderPhone(
    UpdateDataProviderPhonePayload payload,
  ) async {
    final Either result = await serviceLocator<PumpStationApiService>()
        .updateDataProviderPhone(payload);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(
        PumpStationDetailView.fromJson(response.data as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<Either> userOfPumpStation(UserOfPumpStationParam param) async {
    Either result = await serviceLocator<PumpStationApiService>()
        .userOfPumpStation(param);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpUsersResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> getPumpLiveStatus(int userId) async {
    Either result = await serviceLocator<PumpStationApiService>()
        .getPumpLiveStatus(userId);
    return result.fold((error) => Left(error), (data) {
      Response response = data;
      return Right(PumpLiveStatusResponse.fromJson(response.data));
    });
  }

  @override
  Future<Either> createPumpStation(PumpStationCreationPayload payload) async {
    final Either result = await serviceLocator<PumpStationApiService>()
        .createPumpStation(payload);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(
        PumpStationCreationResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    });
  }
}
