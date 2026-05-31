// lib/common/bloc/complaint/complaint_update_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/all_complaint/update_complaint_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintUpdateCubit extends Cubit<ComplaintUpdateState> {
  ComplaintUpdateCubit() : super(ComplaintUpdateInitialState());

  void updateComplaint({
    required UseCase useCase,
    required int complaintId,
    dynamic params,
  }) async {
    emit(ComplaintUpdateLoadingState(complaintId: complaintId));
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(ComplaintUpdateFailureState(errorMessage: error));
        },
        (data) {
          emit(ComplaintUpdateSuccessState(complaintId: complaintId));
        },
      );
    } catch (e) {
      emit(ComplaintUpdateFailureState(errorMessage: e.toString()));
    }
  }

  void resetState() {
    emit(ComplaintUpdateInitialState());
  }
}
