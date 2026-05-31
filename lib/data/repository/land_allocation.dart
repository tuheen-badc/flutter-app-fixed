import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/land_allocation_creation_payload.dart';
import 'package:demo_app/data/models/land_allocation_delete_payload.dart';
import 'package:demo_app/data/models/land_allocation_dto.dart';
import 'package:demo_app/data/models/land_allocation_update_payload.dart';
import 'package:demo_app/data/source/land_allocation_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../../domain/repository/land-allocation.dart';

class LandAllocationRepositoryImplementation extends LandAllocationRepository {
  @override
  Future<Either> getAllLandAllocations(int pumpStationId) async {
    Either result = await serviceLocator<LandAllocationApiService>()
        .getAllLandAllocations(pumpStationId);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        List<dynamic> jsonData = response.data;
        List<LandAllocationDto> landAllocationDtos = jsonData
            .map((row) => LandAllocationDto.fromJson(row))
            .toList();
        return Right(landAllocationDtos);
      },
    );
  }

  @override
  Future<Either> allocateLandOfUser(
    LandAllocationCreationPayload payload,
  ) async {
    Either result = await serviceLocator<LandAllocationApiService>()
        .allocateLandOfUser(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(LandAllocationDto.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> updateLandAllocationOfUser(
    LandAllocationUpdatePayload payload,
  ) async {
    Either result = await serviceLocator<LandAllocationApiService>()
        .updateLandAllocationOfUser(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(LandAllocationDto.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> deleteAllocatedLandOfUser(
    LandAllocationDeletePayload payload,
  ) async {
    Either result = await serviceLocator<LandAllocationApiService>()
        .deleteAllocatedLandOfUser(payload);
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
}
