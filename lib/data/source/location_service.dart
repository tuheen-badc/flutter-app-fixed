import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
import '../models/location.dart';

abstract class LocationApiService {
  Future<List<Division>> fetchDivisions();

  Future<List<District>> fetchDistricts(int divisionId);

  Future<List<Upazilla>> fetchUpazillas(int districtId);

  Future<List<Union>> fetchUnions(int upazillaId);

  Future<List<PumpStation>> fetchPumpStations({
    required int divisionId,
    required int districtId,
    int? upazillaId,
    int? unionId,
  });
}

class LocationApiServiceImplementation extends LocationApiService {
  DioClient get _client => serviceLocator<DioClient>();

  Future<Options> _authOptions() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<Division>> fetchDivisions() async {
    try {
      final res = await _client.get(
        ApiUrls.divisions,
        options: await _authOptions(),
      );
      return (res.data as List)
          .map((e) => Division.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  @override
  Future<List<District>> fetchDistricts(int divisionId) async {
    try {
      final res = await _client.get(
        ApiUrls.districts,
        options: await _authOptions(),
        queryParameters: {'divisionId': divisionId},
      );
      return (res.data as List)
          .map((e) => District.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  @override
  Future<List<Upazilla>> fetchUpazillas(int districtId) async {
    try {
      final res = await _client.get(
        ApiUrls.upazillas,
        options: await _authOptions(),
        queryParameters: {'districtId': districtId},
      );
      return (res.data as List)
          .map((e) => Upazilla.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  @override
  Future<List<Union>> fetchUnions(int upazillaId) async {
    try {
      final res = await _client.get(
        ApiUrls.unions,
        options: await _authOptions(),
        queryParameters: {'upazillaId': upazillaId},
      );
      return (res.data as List)
          .map((e) => Union.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  @override
  Future<List<PumpStation>> fetchPumpStations({
    required int divisionId,
    required int districtId,
    int? upazillaId,
    int? unionId,
  }) async {
    try {
      print("before api call");

      final res = await _client.get(
        ApiUrls.pumpStationListPlain,
        options: await _authOptions(),
        queryParameters: {
          'divisionId': divisionId,
          'districtId': districtId,
          'upazillaId': upazillaId,
          'unionId': unionId,
        },
      );
      return (res.data as List)
          .map((e) => PumpStation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  String _extractMessage(DioException e) {
    final dynamic body = e.response?.data;
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    return e.message ?? 'Something went wrong';
  }
}
