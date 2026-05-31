// user_analytics_state.dart

import '../../../data/models/user_specific_analytics.dart';

abstract class UserAnalyticsState {}

class UserAnalyticsInitialState extends UserAnalyticsState {}

class UserAnalyticsLoadingState extends UserAnalyticsState {}

class UserAnalyticsLoadedState extends UserAnalyticsState {
  final UserAnalyticsResponse analyticsData;

  UserAnalyticsLoadedState({required this.analyticsData});
}

class UserAnalyticsErrorState extends UserAnalyticsState {
  final String errorMessage;

  UserAnalyticsErrorState({required this.errorMessage});
}
