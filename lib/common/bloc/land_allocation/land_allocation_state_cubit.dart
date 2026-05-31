// common/bloc/land_allocation/land_allocation_state_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/land_allocation/land_allocation_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/land_allocation_delete_payload.dart';
import 'package:demo_app/data/models/land_allocation_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandAllocationCubit extends Cubit<LandAllocationState> {
  LandAllocationCubit() : super(LandAllocationInitialState());

  Future<void> loadLandAllocation({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(LandAllocationLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(LandAllocationErrorState(errorMessage: error));
        },
        (data) {
          emit(LandAllocationLoadedState(allocationList: data));
        },
      );
    } catch (e) {
      emit(LandAllocationErrorState(errorMessage: e.toString()));
    }
  }

  void refreshLandAllocation({required UseCase useCase, dynamic params}) {
    loadLandAllocation(useCase: useCase, params: params);
  }

  // Add new allocation to the list locally (no network call)
  void addAllocation(LandAllocationDto allocation) {
    final currentState = state;
    if (currentState is LandAllocationLoadedState) {
      final updatedList = List<LandAllocationDto>.from(
        currentState.allocationList,
      )..add(allocation);
      emit(LandAllocationLoadedState(allocationList: updatedList));
    }
  }

  // Update existing allocation in the list locally (no network call)
  void updateAllocation(LandAllocationDto updatedAllocation) {
    final currentState = state;
    if (currentState is LandAllocationLoadedState) {
      final updatedList = currentState.allocationList.map((allocation) {
        if (allocation.id == updatedAllocation.id) {
          return updatedAllocation;
        }
        return allocation;
      }).toList();
      emit(LandAllocationLoadedState(allocationList: updatedList));
    }
  }

  // Remove allocation from the list locally (no network call)
  void removeAllocation(int allocationId) {
    final currentState = state;
    if (currentState is LandAllocationLoadedState) {
      final updatedList = currentState.allocationList
          .where((allocation) => allocation.id != allocationId)
          .toList();
      emit(LandAllocationLoadedState(allocationList: updatedList));
    }
  }
}

// common/bloc/create_land_allocation/create_land_allocation_button_cubit.dart
class CreateLandAllocationButtonCubit
    extends Cubit<CreateLandAllocationButtonState> {
  CreateLandAllocationButtonCubit()
    : super(CreateLandAllocationButtonInitialState());

  void createLandAllocation({dynamic params, required UseCase useCase}) async {
    emit(CreateLandAllocationButtonLoadingState());

    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(CreateLandAllocationButtonFailureState(errorMessage: error));
        },
        (data) {
          // Emit success with the created allocation data from the response
          emit(
            CreateLandAllocationButtonSuccessState(
              allocation: data as LandAllocationDto,
            ),
          );
        },
      );
    } catch (e) {
      emit(CreateLandAllocationButtonFailureState(errorMessage: e.toString()));
    }
  }
}

// common/bloc/update_land_allocation/update_land_allocation_button_cubit.dart
class UpdateLandAllocationButtonCubit
    extends Cubit<UpdateLandAllocationButtonState> {
  UpdateLandAllocationButtonCubit()
    : super(UpdateLandAllocationButtonInitialState());

  void updateLandAllocation({dynamic params, required UseCase useCase}) async {
    emit(UpdateLandAllocationButtonLoadingState());

    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdateLandAllocationButtonFailureState(errorMessage: error));
        },
        (data) {
          // Emit success with the updated allocation data from the response
          emit(
            UpdateLandAllocationButtonSuccessState(
              allocation: data as LandAllocationDto,
            ),
          );
        },
      );
    } catch (e) {
      emit(UpdateLandAllocationButtonFailureState(errorMessage: e.toString()));
    }
  }
}

// common/bloc/delete_land_allocation/delete_land_allocation_button_cubit.dart
class DeleteLandAllocationButtonCubit
    extends Cubit<DeleteLandAllocationButtonState> {
  DeleteLandAllocationButtonCubit()
    : super(DeleteLandAllocationButtonInitialState());

  void deleteLandAllocation({dynamic params, required UseCase useCase}) async {
    emit(DeleteLandAllocationButtonLoadingState());

    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(DeleteLandAllocationButtonFailureState(errorMessage: error));
        },
        (data) {
          // On successful deletion, emit success with the deleted allocation ID
          final deletedId =
              (params as LandAllocationDeletePayload).allocationId;
          emit(DeleteLandAllocationButtonSuccessState(allocationId: deletedId));
        },
      );
    } catch (e) {
      emit(DeleteLandAllocationButtonFailureState(errorMessage: e.toString()));
    }
  }
}
