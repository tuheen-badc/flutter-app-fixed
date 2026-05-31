// electricity_availability_cubit.dart
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'electricity_status_state.dart';

class ElectricityAvailabilityCubit extends Cubit<ElectricityAvailabilityState> {
  ElectricityAvailabilityCubit() : super(ElectricityAvailabilityInitialState());

  Future<void> loadElectricityStatus({
    dynamic params,
    required UseCase useCase,
  }) async {
    emit(ElectricityAvailabilityLoadingState());

    try {
      final result = await useCase.call(param: params);

      result.fold(
        (failure) {
          emit(ElectricityAvailabilityErrorState(failure.message));
        },
        (response) {
          emit(
            ElectricityAvailabilityLoadedState(
              statusList: response.indicators,
              currentPage: response.currentPage,
              totalPages: response.totalPages,
              totalElements: response.totalElements,
            ),
          );
        },
      );
    } catch (e) {
      emit(ElectricityAvailabilityErrorState(e.toString()));
    }
  }
}
