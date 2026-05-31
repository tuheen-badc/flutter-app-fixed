// common/bloc/pump_detail_edit/pump_detail_edit_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_station_detail/pump_station_detail_edit_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpDetailEditCubit extends Cubit<PumpDetailEditState> {
  PumpDetailEditCubit() : super(PumpDetailEditInitialState());

  Future<void> updateLocation({
    required UseCase useCase,
    required dynamic params,
  }) => _runEdit(useCase: useCase, params: params);

  Future<void> updateManagerPhone({
    required UseCase useCase,
    required dynamic params,
  }) => _runEdit(useCase: useCase, params: params);

  Future<void> updateDataProviderPhone({
    required UseCase useCase,
    required dynamic params,
  }) => _runEdit(useCase: useCase, params: params);

  Future<void> _runEdit({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(PumpDetailEditLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) =>
            emit(PumpDetailEditErrorState(errorMessage: error.toString())),
        (data) => emit(PumpDetailEditSuccessState(updatedDetail: data)),
      );
    } catch (e) {
      emit(PumpDetailEditErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() => emit(PumpDetailEditInitialState());
}
