// user_block_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/user_block/user_block_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBlockCubit extends Cubit<UserBlockState> {
  UserBlockCubit() : super(UserBlockInitialState());

  void toggleBlockStatus({
    required UseCase useCase,
    required int userId,
    required dynamic params,
  }) async {
    emit(UserBlockLoadingState(userId: userId));

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(UserBlockFailureState(userId: userId, errorMessage: error));
        },
        (data) {
          // Assuming the API returns the updated blocked status
          final blocked = params.blocked;
          emit(
            UserBlockSuccessState(
              userId: userId,
              blocked: blocked,
              message: blocked
                  ? 'User blocked successfully'
                  : 'User unblocked successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(UserBlockFailureState(userId: userId, errorMessage: e.toString()));
    }
  }

  void resetState() {
    emit(UserBlockInitialState());
  }
}
