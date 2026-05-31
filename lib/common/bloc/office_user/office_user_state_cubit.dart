import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'office_user_state.dart';

class OfficeUserListCubit extends Cubit<OfficeUserListState> {
  OfficeUserListCubit() : super(OfficeUserListInitialState());

  void loadOfficeUsers({required UseCase useCase, dynamic params}) async {
    emit(OfficeUserListLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) => emit(OfficeUserListErrorState(errorMessage: error)),
        (data) => emit(
          OfficeUserListLoadedState(
            userList: data.userList,
            totalElements: data.totalElements,
            totalPages: data.totalPages,
            currentPage: data.currentPage,
          ),
        ),
      );
    } catch (e) {
      emit(OfficeUserListErrorState(errorMessage: e.toString()));
    }
  }
}
