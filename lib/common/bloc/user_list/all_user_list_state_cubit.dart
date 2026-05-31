// all_user_list_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'all_user_list_state.dart';

class AllUserListCubit extends Cubit<AllUserListState> {
  AllUserListCubit() : super(AllUserListInitialState());

  void loadUsers({required UseCase useCase, dynamic params}) async {
    emit(AllUserListLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(AllUserListErrorState(errorMessage: error));
        },
        (data) {
          emit(
            AllUserListLoadedState(
              userList: data.userList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(AllUserListErrorState(errorMessage: e.toString()));
    }
  }
}
