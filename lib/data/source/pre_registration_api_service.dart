import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/official_pre_registration_criteria.dart';
import 'package:demo_app/data/models/official_pre_registration_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pre_registration_deletion_param.dart';

abstract class PreRegistrationApiService {
  Future<Either> allPreRegistration(OfficialPreRegistrationCriteria criteria);

  Future<Either> deletePreRegistration(PreRegistrationDeletionParam param);

  Future<Either> createPreRegistration(OfficialPreRegistrationPayload payload);
}

class PreRegistrationApiServiceImplementation
    extends PreRegistrationApiService {
  @override
  Future<Either> allPreRegistration(
    OfficialPreRegistrationCriteria criteria,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.allPreRegistrations(criteria.officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toQueryParams(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> deletePreRegistration(
    PreRegistrationDeletionParam param,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().delete(
        ApiUrls.deletePreRegistrations(param.officeId, param.registrationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> createPreRegistration(
    OfficialPreRegistrationPayload payload,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.createPreRegistrations(payload.officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
