// common/bloc/pump_users/pump_users_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/users_of_pump/users_of_pump_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpUsersCubit extends Cubit<PumpUsersState> {
  PumpUsersCubit() : super(PumpUsersInitialState());

  Future<void> loadPumpUsers({required UseCase useCase, dynamic params}) async {
    emit(PumpUsersLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(PumpUsersErrorState(errorMessage: error));
        },
        (data) {
          emit(
            PumpUsersLoadedState(
              userList: data.userList,
              currentPage: data.currentPage,
              totalPages: data.totalPages,
              totalElements: data.totalElements,
            ),
          );
        },
      );
    } catch (e) {
      emit(PumpUsersErrorState(errorMessage: e.toString()));
    }
  }

  void refreshUsers({required UseCase useCase, dynamic params}) {
    loadPumpUsers(useCase: useCase, params: params);
  }
}
