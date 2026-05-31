import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/ComplaintCreationModel.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/complaint.dart';

abstract class ComplaintApiService {
  Future<Either> submitComplaint(ComplaintCreationModel payload);

  Future<Either> getAllComplaints(ComplaintCriteria criteria);

  Future<Either> updateComplaint(int complaintId, ComplaintUpdateModel model);
}

class ComplaintApiServiceImplementation extends ComplaintApiService {
  @override
  Future<Either> submitComplaint(ComplaintCreationModel payload) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var response = await serviceLocator<DioClient>().post(
        ApiUrls.submitComplaint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> getAllComplaints(ComplaintCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.complaints,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to load complaints');
    }
  }

  @override
  Future<Either> updateComplaint(
    int complaintId,
    ComplaintUpdateModel model,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().put(
        ApiUrls.updateComplaint(complaintId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: model.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to update complaint');
    }
  }
}
