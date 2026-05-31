// pump_station_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/all_pump_list/all_pump_station_list_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllPumpStationCubit extends Cubit<AllPumpStationState> {
  AllPumpStationCubit() : super(AllPumpStationInitialState());

  void loadPumpStations({required UseCase useCase, dynamic params}) async {
    emit(AllPumpStationLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(AllPumpStationErrorState(errorMessage: error));
        },
        (data) {
          emit(
            AllPumpStationLoadedState(
              stationList: data.stationList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(AllPumpStationErrorState(errorMessage: e.toString()));
    }
  }
}
