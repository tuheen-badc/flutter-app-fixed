import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/land_allocation_creation_payload.dart';
import 'package:demo_app/data/models/land_allocation_delete_payload.dart';
import 'package:demo_app/data/models/land_allocation_update_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LandAllocationApiService {
  Future<Either> getAllLandAllocations(int pumpStationId);

  Future<Either> allocateLandOfUser(LandAllocationCreationPayload payload);

  Future<Either> updateLandAllocationOfUser(
    LandAllocationUpdatePayload payload,
  );

  Future<Either> deleteAllocatedLandOfUser(LandAllocationDeletePayload payload);
}

class LandAllocationApiServiceImplementation extends LandAllocationApiService {
  @override
  Future<Either> getAllLandAllocations(int pumpStationId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.getAllLandAllocations(pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> allocateLandOfUser(
    LandAllocationCreationPayload payload,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.createLandAllocation(payload.pumpStationId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updateLandAllocationOfUser(
    LandAllocationUpdatePayload payload,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().put(
        ApiUrls.updateLandAllocation(
          payload.pumpStationId,
          payload.allocationId,
        ),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> deleteAllocatedLandOfUser(
    LandAllocationDeletePayload payload,
  ) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().delete(
        ApiUrls.deleteLandAllocation(
          payload.pumpStationId,
          payload.allocationId,
        ),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
