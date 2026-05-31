// common/bloc/pump_analytics/pump_analytics_state.dart
import '../../../data/models/pump_analytics_response.dart';

abstract class PumpAnalyticsState {}

class PumpAnalyticsInitialState extends PumpAnalyticsState {}

class PumpAnalyticsLoadingState extends PumpAnalyticsState {}

class PumpAnalyticsLoadedState extends PumpAnalyticsState {
  final PumpAnalyticsResponse analytics;

  PumpAnalyticsLoadedState({required this.analytics});
}

class PumpAnalyticsErrorState extends PumpAnalyticsState {
  final String errorMessage;

  PumpAnalyticsErrorState({required this.errorMessage});
}
