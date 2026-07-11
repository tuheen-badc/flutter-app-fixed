// electricity_availability_cubit.dart
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/electricity_status.dart';
import '../../../data/models/electricity_history.dart';
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

  /// Special handler to fetch the latest status from history endpoint for a specific station.
  /// This is used when the indicators endpoint fails to return data for a known station.
  Future<void> loadFromHistory({
    required UseCase useCase,
    required dynamic params,
    required String stationName,
    String? division,
    String? district,
    String? upazilla,
    String? union,
  }) async {
    emit(ElectricityAvailabilityLoadingState());

    try {
      final result = await useCase.call(param: params);

      result.fold(
        (failure) {
          emit(ElectricityAvailabilityErrorState(failure.message));
        },
        (response) {
          final history = response as ElectricityStatusHistoryResponse;
          
          if (history.historyList.isEmpty) {
            emit(const ElectricityAvailabilityLoadedState(
              statusList: [],
              currentPage: 0,
              totalPages: 0,
              totalElements: 0,
            ));
            return;
          }

          // Sort by date descending to ensure we get the absolute latest status
          final sortedList = List<ElectricityStatusHistoryItem>.from(history.historyList);
          sortedList.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
          
          final latest = sortedList.first;
          final indicator = ElectricityAvailabilityIndicator(
            name: stationName,
            divisionName: division ?? '',
            districtName: district ?? '',
            upazillaName: upazilla ?? '',
            unionName: union ?? '',
            lastUpdatedAt: latest.loggedAt,
            phaseOneAvailable: latest.phaseOneAvailable,
            phaseTwoAvailable: latest.phaseTwoAvailable,
            phaseThreeAvailable: latest.phaseThreeAvailable,
          );

          emit(
            ElectricityAvailabilityLoadedState(
              statusList: [indicator],
              currentPage: 0,
              totalPages: 1,
              totalElements: 1,
            ),
          );
        },
      );
    } catch (e) {
      emit(ElectricityAvailabilityErrorState(e.toString()));
    }
  }
}
