// common/bloc/pump_analytics/pump_analytics_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/pump_analytics/pump_analytics_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PumpAnalyticsCubit extends Cubit<PumpAnalyticsState> {
  PumpAnalyticsCubit() : super(PumpAnalyticsInitialState());

  void loadAnalytics({required UseCase useCase, dynamic params}) async {
    emit(PumpAnalyticsLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) => emit(PumpAnalyticsErrorState(errorMessage: error)),
        (data) => emit(PumpAnalyticsLoadedState(analytics: data)),
      );
    } catch (e) {
      emit(PumpAnalyticsErrorState(errorMessage: e.toString()));
    }
  }
}
