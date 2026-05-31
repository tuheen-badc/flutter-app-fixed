// office_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/office_response.dart';
import 'package:demo_app/data/source/office_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../../domain/repository/office.dart';
import '../models/office_creation_payload.dart';
import '../models/office_creation_response.dart';
import '../models/office_detail_model.dart';
import '../models/office_fetch_criteria.dart';
import '../models/office_pump_criteria.dart';
import '../models/office_pump_response.dart';
import '../models/office_user_list_criteria.dart';
import '../models/office_user_list_response.dart';

class OfficeRepositoryImplementation extends OfficeRepository {
  @override
  Future<Either> allOfficeList(OfficeCriteria criteria) async {
    Either result = await serviceLocator<OfficeApiService>().allOfficeList(
      criteria,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(OfficeResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> officeUserList(OfficeUserListCriteria criteria) async {
    final Either result = await serviceLocator<OfficeApiService>()
        .officeUserList(criteria);

    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(OfficeUserListResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> officePumpList(OfficePumpCriteria criteria) async {
    final Either result = await serviceLocator<OfficeApiService>()
        .officePumpList(criteria);
    return result.fold(
      (error) => Left(error),
      (data) => Right(OfficePumpResponse.fromJson((data as Response).data)),
    );
  }

  @override
  Future<Either> getOfficeDetail(int officeId) async {
    final Either result = await serviceLocator<OfficeApiService>()
        .getOfficeDetail(officeId);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(OfficeDetail.fromJson(response.data));
    });
  }

  @override
  Future<Either> updateOfficeLocation(UpdateOfficeLocationPayload p) async {
    final Either result = await serviceLocator<OfficeApiService>()
        .updateOfficeLocation(p);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(OfficeDetail.fromJson(response.data));
    });
  }

  @override
  Future<Either> updateOfficeContact(UpdateOfficeContactPayload p) async {
    final Either result = await serviceLocator<OfficeApiService>()
        .updateOfficeContact(p);
    return result.fold((error) => Left(error), (data) {
      final Response response = data as Response;
      return Right(OfficeDetail.fromJson(response.data));
    });
  }

  @override
  Future<Either> createOffice(OfficeCreationPayload payload) async {
    Either result =
    await serviceLocator<OfficeApiService>().createOffice(payload);
    return result.fold(
          (error) {
        return Left(error);
      },
          (data) async {
        Response response = data;
        return Right(OfficeCreationResponse.fromJson(response.data));
      },
    );
  }
}
