// electricity_history_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/electricity_history/electricity_history_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElectricityHistoryCubit extends Cubit<ElectricityHistoryState> {
  ElectricityHistoryCubit() : super(ElectricityHistoryInitialState());

  void loadElectricityHistory({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(ElectricityHistoryLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
            (error) {
          emit(ElectricityHistoryErrorState(errorMessage: error));
        },
            (data) {
          emit(
            ElectricityHistoryLoadedState(
              historyList: data.historyList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(ElectricityHistoryErrorState(errorMessage: e.toString()));
    }
  }
}