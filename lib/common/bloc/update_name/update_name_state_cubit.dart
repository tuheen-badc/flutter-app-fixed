// cubits/user_profile_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/update_name/update_name_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateNameScreenCubit extends Cubit<UpdateNameScreenState> {
  UpdateNameScreenCubit() : super(UpdateNameScreenInitialState());

  void loadName({required UseCase useCase, dynamic params}) async {
    emit(UpdateNameScreenLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdateNameScreenErrorState(errorMessage: error));
        },
        (data) {
          // Assuming data contains firstName and lastName
          emit(
            UpdateNameScreenLoadedState(
              firstName: data.firstName,
              lastName: data.lastName,
            ),
          );
        },
      );
    } catch (e) {
      emit(UpdateNameScreenErrorState(errorMessage: e.toString()));
    }
  }
}

class UpdateNameButtonStateCubit extends Cubit<UpdateNameButtonState> {
  UpdateNameButtonStateCubit() : super(UpdateNameButtonInitialState());

  void updateName({dynamic params, required UseCase useCase}) async {
    emit(UpdateNameButtonLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdateNameButtonFailureState(errorMessage: error));
        },
        (data) {
          emit(UpdateNameButtonSuccessState());
        },
      );
    } catch (e) {
      emit(UpdateNameButtonFailureState(errorMessage: e.toString()));
    }
  }
}
