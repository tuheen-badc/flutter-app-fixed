// common/bloc/pump_detail_view/pump_detail_view_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_station_detail/pump_station_detail_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpDetailViewCubit extends Cubit<PumpDetailViewState> {
  PumpDetailViewCubit() : super(PumpDetailViewInitialState());

  Future<void> loadDetail({
    required UseCase useCase,
    required int pumpStationId,
  }) async {
    emit(PumpDetailViewLoadingState());
    try {
      final Either result = await useCase.call(param: pumpStationId);
      result.fold(
        (error) =>
            emit(PumpDetailViewErrorState(errorMessage: error.toString())),
        (data) => emit(PumpDetailViewLoadedState(detail: data)),
      );
    } catch (e) {
      emit(PumpDetailViewErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> refresh({
    required UseCase useCase,
    required int pumpStationId,
  }) => loadDetail(useCase: useCase, pumpStationId: pumpStationId);
}
