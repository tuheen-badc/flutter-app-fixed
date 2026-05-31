// overall_analytics_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'overall_ananlytics_state.dart';

class OverallAnalyticsCubit extends Cubit<OverallAnalyticsState> {
  OverallAnalyticsCubit() : super(OverallAnalyticsInitialState());

  void loadAnalytics({required UseCase useCase}) async {
    emit(OverallAnalyticsLoadingState());
    try {
      Either result = await useCase.call();
      result.fold(
        (error) {
          emit(OverallAnalyticsErrorState(errorMessage: error));
        },
        (data) {
          emit(OverallAnalyticsLoadedState(analytics: data));
        },
      );
    } catch (e) {
      emit(OverallAnalyticsErrorState(errorMessage: e.toString()));
    }
  }

  void refresh({required UseCase useCase}) {
    loadAnalytics(useCase: useCase);
  }
}
