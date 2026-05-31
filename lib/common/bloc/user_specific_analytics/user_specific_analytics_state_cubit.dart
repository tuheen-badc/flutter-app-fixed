// user_analytics_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/user_specific_analytics/user_specific_analytics_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAnalyticsCubit extends Cubit<UserAnalyticsState> {
  UserAnalyticsCubit() : super(UserAnalyticsInitialState());

  void loadUserAnalytics({
    required UseCase useCase,
    required int userId,
  }) async {
    emit(UserAnalyticsLoadingState());
    try {
      Either result = await useCase.call(param: userId);
      result.fold(
        (error) {
          emit(UserAnalyticsErrorState(errorMessage: error));
        },
        (data) {
          emit(UserAnalyticsLoadedState(analyticsData: data));
        },
      );
    } catch (e) {
      emit(UserAnalyticsErrorState(errorMessage: e.toString()));
    }
  }
}
