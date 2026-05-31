import 'package:demo_app/data/models/water_pricing_response.dart';

import '../../../data/models/user_tier_list.dart';

abstract class TierInfoState {}

class TierInfoInitialState extends TierInfoState {}

class TierInfoLoadingState extends TierInfoState {}

class TierInfoLoadedState extends TierInfoState {
  final List<PumpStationTierInfo> tierList;
  final int selectedIndex;
  final WaterPricingResponse waterPricingResponse;

  TierInfoLoadedState({
    required this.tierList,
    this.selectedIndex = 0,
    required this.waterPricingResponse,
  });

  PumpStationTierInfo get selectedTier => tierList[selectedIndex];

  TierInfoLoadedState copyWith({int? selectedIndex}) {
    return TierInfoLoadedState(
      tierList: tierList,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      waterPricingResponse: waterPricingResponse,
    );
  }
}

class TierInfoEmptyState extends TierInfoState {
  final WaterPricingResponse waterPricingResponse;

  TierInfoEmptyState({required this.waterPricingResponse});
}

class TierInfoErrorState extends TierInfoState {
  final String errorMessage;

  TierInfoErrorState({required this.errorMessage});
}
