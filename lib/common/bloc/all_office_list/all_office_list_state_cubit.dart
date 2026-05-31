// all_office_list_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/all_office_list/all_office_list_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllOfficeCubit extends Cubit<AllOfficeState> {
  AllOfficeCubit() : super(AllOfficeInitialState());

  void loadOffices({required UseCase useCase, dynamic params}) async {
    emit(AllOfficeLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(AllOfficeErrorState(errorMessage: error));
        },
        (data) {
          emit(
            AllOfficeLoadedState(
              officeList: data.officeList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(AllOfficeErrorState(errorMessage: e.toString()));
    }
  }
}
