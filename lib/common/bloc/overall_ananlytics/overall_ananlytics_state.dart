// overall_analytics_state.dart
import '../../../data/models/AnalyticsResponse.dart';

abstract class OverallAnalyticsState {}

class OverallAnalyticsInitialState extends OverallAnalyticsState {}

class OverallAnalyticsLoadingState extends OverallAnalyticsState {}

class OverallAnalyticsLoadedState extends OverallAnalyticsState {
  final AnalyticsResponse analytics;

  OverallAnalyticsLoadedState({required this.analytics});
}

class OverallAnalyticsErrorState extends OverallAnalyticsState {
  final String errorMessage;

  OverallAnalyticsErrorState({required this.errorMessage});
}