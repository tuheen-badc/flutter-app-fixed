// common/bloc/office_analytics/user_pump_live_status_state.dart
import '../../../data/models/office_analytics_response.dart';

abstract class OfficeAnalyticsState {}

class OfficeAnalyticsInitialState extends OfficeAnalyticsState {}

class OfficeAnalyticsLoadingState extends OfficeAnalyticsState {}

class OfficeAnalyticsLoadedState extends OfficeAnalyticsState {
  final OfficeAnalyticsResponse analytics;
  OfficeAnalyticsLoadedState({required this.analytics});
}

class OfficeAnalyticsErrorState extends OfficeAnalyticsState {
  final String errorMessage;
  OfficeAnalyticsErrorState({required this.errorMessage});
}