// pump_station_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_list/pump_station_list_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpStationCubit extends Cubit<PumpStationState> {
  PumpStationCubit() : super(PumpStationInitialState());

  void loadPumpStations({required UseCase useCase, dynamic params}) async {
    emit(PumpStationLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(PumpStationErrorState(errorMessage: error));
        },
        (data) {
          emit(
            PumpStationLoadedState(
              stationList: data.stationList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(PumpStationErrorState(errorMessage: e.toString()));
    }
  }
}
