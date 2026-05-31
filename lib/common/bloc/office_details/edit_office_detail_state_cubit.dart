import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';
import 'edit_office_detail_state.dart';

class OfficeDetailEditCubit extends Cubit<OfficeDetailEditState> {
  OfficeDetailEditCubit() : super(OfficeDetailEditInitialState());

  Future<void> updateLocation({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(OfficeDetailEditLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) =>
            emit(OfficeDetailEditErrorState(errorMessage: error.toString())),
        (data) => emit(OfficeDetailEditSuccessState(updatedDetail: data)),
      );
    } catch (e) {
      emit(OfficeDetailEditErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> updateContact({
    required UseCase useCase,
    required dynamic params,
  }) async {
    emit(OfficeDetailEditLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) =>
            emit(OfficeDetailEditErrorState(errorMessage: error.toString())),
        (data) => emit(OfficeDetailEditSuccessState(updatedDetail: data)),
      );
    } catch (e) {
      emit(OfficeDetailEditErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() => emit(OfficeDetailEditInitialState());
}
