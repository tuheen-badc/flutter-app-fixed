import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/ComplaintCreationModel.dart';
import 'package:demo_app/data/models/ComplaintCreationResponseModel.dart';
import 'package:demo_app/data/source/complaint_api_service.dart';
import 'package:demo_app/domain/repository/complaint.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/complaint.dart';

class ComplaintRepositoryImplementation extends ComplaintRepository {
  @override
  Future<Either> submitComplaint(ComplaintCreationModel payload) async {
    Either result = await serviceLocator<ComplaintApiService>().submitComplaint(
      payload,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(ComplaintCreationResponseModel.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> getAllComplaints(ComplaintCriteria criteria) async {
    Either result = await serviceLocator<ComplaintApiService>()
        .getAllComplaints(criteria);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(ComplaintResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> updateComplaint(
    int complaintId,
    ComplaintUpdateModel model,
  ) async {
    Either result = await serviceLocator<ComplaintApiService>().updateComplaint(
      complaintId,
      model,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        return Right(data);
      },
    );
  }
}
