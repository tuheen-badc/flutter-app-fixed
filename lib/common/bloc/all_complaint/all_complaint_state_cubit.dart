// lib/common/bloc/complaint/complaint_list_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'all_complaint_state.dart';

class ComplaintListCubit extends Cubit<ComplaintListState> {
  ComplaintListCubit() : super(ComplaintListInitialState());

  void loadComplaints({required UseCase useCase, dynamic params}) async {
    emit(ComplaintListLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(ComplaintListErrorState(errorMessage: error));
        },
        (data) {
          emit(
            ComplaintListLoadedState(
              complaints: data.complaints,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(ComplaintListErrorState(errorMessage: e.toString()));
    }
  }
}
