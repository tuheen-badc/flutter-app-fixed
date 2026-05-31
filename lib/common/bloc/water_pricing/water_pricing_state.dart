import 'package:demo_app/data/models/water_pricing_response.dart';

abstract class WaterPricingState {}

class WaterPricingInitialState extends WaterPricingState {}

class WaterPricingLoadingState extends WaterPricingState {}

class WaterPricingLoadedState extends WaterPricingState {
  final WaterPricingResponse pricing;

  WaterPricingLoadedState({required this.pricing});
}

class WaterPricingErrorState extends WaterPricingState {
  final String errorMessage;

  WaterPricingErrorState({required this.errorMessage});
}
