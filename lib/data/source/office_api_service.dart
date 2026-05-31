// office_api_service.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/office_creation_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/office_detail_model.dart';
import '../models/office_fetch_criteria.dart';
import '../models/office_pump_criteria.dart';
import '../models/office_user_list_criteria.dart';

abstract class OfficeApiService {
  Future<Either> allOfficeList(OfficeCriteria criteria);

  Future<Either> officeUserList(OfficeUserListCriteria criteria);

  Future<Either> officePumpList(OfficePumpCriteria criteria);

  Future<List<Office>> fetchOffices({
    required int divisionId,
    required int districtId,
    int? upazillaId,
    int? unionId,
  });

  Future<Either> getOfficeDetail(int officeId);

  Future<Either> updateOfficeLocation(UpdateOfficeLocationPayload payload);

  Future<Either> updateOfficeContact(UpdateOfficeContactPayload payload);

  Future<Either> createOffice(OfficeCreationPayload payload);
}

class OfficeApiServiceImplementation extends OfficeApiService {
  DioClient get _client => serviceLocator<DioClient>();

  @override
  Future<Either> allOfficeList(OfficeCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.allOfficeList,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> officeUserList(OfficeUserListCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      final response = await serviceLocator<DioClient>().get(
        ApiUrls.officeUsers(criteria.officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<Either> officePumpList(OfficePumpCriteria criteria) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await serviceLocator<DioClient>().get(
        ApiUrls.officePumps(criteria.officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<List<Office>> fetchOffices({
    required int divisionId,
    required int districtId,
    int? upazillaId,
    int? unionId,
  }) async {
    try {
      final res = await _client.get(
        ApiUrls.officeListPlain,
        options: await _authOptions(),
        queryParameters: {
          'divisionId': divisionId,
          'districtId': districtId,
          'upazillaId': upazillaId,
          'unionId': unionId,
        },
      );
      return (res.data as List)
          .map((e) => Office.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  Future<Options> _authOptions() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _extractMessage(DioException e) {
    final dynamic body = e.response?.data;
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    return e.message ?? 'Something went wrong';
  }

  @override
  Future<Either> getOfficeDetail(int officeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final Response response = await serviceLocator<DioClient>().get(
        ApiUrls.officeDetail(officeId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<Either> updateOfficeLocation(
    UpdateOfficeLocationPayload payload,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.updateOfficeLocation(payload.officeId),
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

  @override
  Future<Either> updateOfficeContact(UpdateOfficeContactPayload payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.updateOfficeContact(payload.officeId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/update-office-contact+json',
        ),
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<Either> createOffice(OfficeCreationPayload payload) async {
    try {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.createOffice,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

}
