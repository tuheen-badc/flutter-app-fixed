// update_water_pricing_state.dart
abstract class UpdateWaterPricingState {}

class UpdateWaterPricingInitialState extends UpdateWaterPricingState {}

class UpdateWaterPricingLoadingState extends UpdateWaterPricingState {}

class UpdateWaterPricingSuccessState extends UpdateWaterPricingState {
  final String message;

  UpdateWaterPricingSuccessState({required this.message});
}

class UpdateWaterPricingErrorState extends UpdateWaterPricingState {
  final String errorMessage;

  UpdateWaterPricingErrorState({required this.errorMessage});
}
