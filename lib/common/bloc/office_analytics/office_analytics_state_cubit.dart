// common/bloc/office_analytics/office_analytics_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/office_analytics/office_analytics_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfficeAnalyticsCubit extends Cubit<OfficeAnalyticsState> {
  OfficeAnalyticsCubit() : super(OfficeAnalyticsInitialState());

  void loadAnalytics({required UseCase useCase, dynamic params}) async {
    emit(OfficeAnalyticsLoadingState());
    try {
      final Either result = await useCase.call(param: params);
      result.fold(
        (error) => emit(OfficeAnalyticsErrorState(errorMessage: error)),
        (data) => emit(OfficeAnalyticsLoadedState(analytics: data)),
      );
    } catch (e) {
      emit(OfficeAnalyticsErrorState(errorMessage: e.toString()));
    }
  }
}
