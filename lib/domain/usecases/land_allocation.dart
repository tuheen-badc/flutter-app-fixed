import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/land_allocation_creation_payload.dart';
import 'package:demo_app/data/models/land_allocation_delete_payload.dart';
import 'package:demo_app/data/models/land_allocation_update_payload.dart';
import 'package:demo_app/domain/repository/land-allocation.dart';
import 'package:demo_app/service_locator.dart';

class GetLandAllocationUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<LandAllocationRepository>().getAllLandAllocations(
      param!,
    );
  }
}

class CreateLandAllocationUseCase
    implements UseCase<Either, LandAllocationCreationPayload> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<LandAllocationRepository>().allocateLandOfUser(
      param!,
    );
  }
}

class UpdateLandAllocationUseCase
    implements UseCase<Either, LandAllocationUpdatePayload> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<LandAllocationRepository>()
        .updateLandAllocationOfUser(param!);
  }
}

class DeleteLandAllocationUseCase
    implements UseCase<Either, LandAllocationDeletePayload> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<LandAllocationRepository>().deleteAllocatedLandOfUser(
      param!,
    );
  }
}
