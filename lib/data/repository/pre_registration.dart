import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/official_pre_registration.dart';
import 'package:demo_app/data/models/official_pre_registration_criteria.dart';
import 'package:demo_app/data/models/official_pre_registration_payload.dart';
import 'package:demo_app/data/source/pre_registration_api_service.dart';
import 'package:demo_app/domain/repository/pre_registration.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/pre_registration_deletion_param.dart';

class PreRegistrationRepositoryImplementation
    extends PreRegistrationRepository {
  @override
  Future<Either> allPreRegistration(
    OfficialPreRegistrationCriteria criteria,
  ) async {
    Either result = await serviceLocator<PreRegistrationApiService>()
        .allPreRegistration(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(OfficialPreRegistrationResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> deletePreRegistration(PreRegistrationDeletionParam param) async {
    Either result = await serviceLocator<PreRegistrationApiService>()
        .deletePreRegistration(param);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response.data);
      },
    );
  }

  @override
  Future<Either> createPreRegistration(
    OfficialPreRegistrationPayload payload,
  ) async {
    Either result = await serviceLocator<PreRegistrationApiService>()
        .createPreRegistration(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }
}
