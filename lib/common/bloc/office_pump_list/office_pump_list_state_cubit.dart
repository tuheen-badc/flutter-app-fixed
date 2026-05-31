// common/bloc/office_pump_list/office_pump_list_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/office_pump_list/office_pump_list_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfficePumpListCubit extends Cubit<OfficePumpListState> {
  OfficePumpListCubit() : super(OfficePumpListInitialState());

  void loadOfficePumps({required UseCase useCase, dynamic params}) async {
    emit(OfficePumpListLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
            (error) => emit(OfficePumpListErrorState(errorMessage: error)),
            (data) => emit(OfficePumpListLoadedState(
          pumpList: data.pumpList,
          totalElements: data.totalElements,
          totalPages: data.totalPages,
          currentPage: data.currentPage,
        )),
      );
    } catch (e) {
      emit(OfficePumpListErrorState(errorMessage: e.toString()));
    }
  }
}