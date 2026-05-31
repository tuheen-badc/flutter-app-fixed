// common/bloc/land_allocation/land_allocation_state.dart
import '../../../data/models/land_allocation_dto.dart';

abstract class LandAllocationState {}

class LandAllocationInitialState extends LandAllocationState {}

class LandAllocationLoadingState extends LandAllocationState {}

class LandAllocationLoadedState extends LandAllocationState {
  final List<LandAllocationDto> allocationList;

  LandAllocationLoadedState({required this.allocationList});
}

class LandAllocationErrorState extends LandAllocationState {
  final String errorMessage;

  LandAllocationErrorState({required this.errorMessage});
}

// common/bloc/create_land_allocation/create_land_allocation_button_state.dart
abstract class CreateLandAllocationButtonState {}

class CreateLandAllocationButtonInitialState
    extends CreateLandAllocationButtonState {}

class CreateLandAllocationButtonLoadingState
    extends CreateLandAllocationButtonState {}

class CreateLandAllocationButtonSuccessState
    extends CreateLandAllocationButtonState {
  final LandAllocationDto allocation;

  CreateLandAllocationButtonSuccessState({required this.allocation});
}

class CreateLandAllocationButtonFailureState
    extends CreateLandAllocationButtonState {
  final String errorMessage;

  CreateLandAllocationButtonFailureState({required this.errorMessage});
}

// common/bloc/update_land_allocation/update_land_allocation_button_state.dart
abstract class UpdateLandAllocationButtonState {}

class UpdateLandAllocationButtonInitialState
    extends UpdateLandAllocationButtonState {}

class UpdateLandAllocationButtonLoadingState
    extends UpdateLandAllocationButtonState {}

class UpdateLandAllocationButtonSuccessState
    extends UpdateLandAllocationButtonState {
  final LandAllocationDto allocation;

  UpdateLandAllocationButtonSuccessState({required this.allocation});
}

class UpdateLandAllocationButtonFailureState
    extends UpdateLandAllocationButtonState {
  final String errorMessage;

  UpdateLandAllocationButtonFailureState({required this.errorMessage});
}

// common/bloc/delete_land_allocation/delete_land_allocation_button_state.dart
abstract class DeleteLandAllocationButtonState {}

class DeleteLandAllocationButtonInitialState
    extends DeleteLandAllocationButtonState {}

class DeleteLandAllocationButtonLoadingState
    extends DeleteLandAllocationButtonState {}

class DeleteLandAllocationButtonSuccessState
    extends DeleteLandAllocationButtonState {
  final int allocationId;

  DeleteLandAllocationButtonSuccessState({required this.allocationId});
}

class DeleteLandAllocationButtonFailureState
    extends DeleteLandAllocationButtonState {
  final String errorMessage;

  DeleteLandAllocationButtonFailureState({required this.errorMessage});
}
