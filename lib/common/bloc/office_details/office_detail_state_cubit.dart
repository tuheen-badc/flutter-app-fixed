// common/bloc/office_detail/office_detail_cubits.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'office_detail_state.dart';

// ── View cubit ────────────────────────────────────────────────────────────────

class OfficeDetailViewCubit extends Cubit<OfficeDetailViewState> {
  OfficeDetailViewCubit() : super(OfficeDetailViewInitialState());

  Future<void> loadDetail({
    required UseCase useCase,
    required int officeId,
  }) async {
    emit(OfficeDetailViewLoadingState());
    try {
      final Either result = await useCase.call(param: officeId);
      result.fold(
        (error) =>
            emit(OfficeDetailViewErrorState(errorMessage: error.toString())),
        (data) => emit(OfficeDetailViewLoadedState(detail: data)),
      );
    } catch (e) {
      emit(OfficeDetailViewErrorState(errorMessage: e.toString()));
    }
  }

  void refresh({required UseCase useCase, required int officeId}) =>
      loadDetail(useCase: useCase, officeId: officeId);
}
