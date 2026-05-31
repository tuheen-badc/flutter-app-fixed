import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/land_allocation_creation_payload.dart';
import 'package:demo_app/data/models/land_allocation_update_payload.dart';

import '../../data/models/land_allocation_delete_payload.dart';

abstract class LandAllocationRepository {
  Future<Either> getAllLandAllocations(int pumpStationId);

  Future<Either> allocateLandOfUser(LandAllocationCreationPayload payload);

  Future<Either> updateLandAllocationOfUser(
    LandAllocationUpdatePayload payload,
  );

  Future<Either> deleteAllocatedLandOfUser(LandAllocationDeletePayload payload);
}
