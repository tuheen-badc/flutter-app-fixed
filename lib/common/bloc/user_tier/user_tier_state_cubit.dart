import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/user_tier/user_tier_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/water_pricing_response.dart';
import 'package:demo_app/domain/usecases/water_pricing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_tier_list.dart';
import '../../../service_locator.dart';

class TierInfoCubit extends Cubit<TierInfoState> {
  TierInfoCubit() : super(TierInfoInitialState());

  void loadTierInfo({
    required UseCase useCase,
    int? targetPumpStationId,
    int? userId,
  }) async {
    emit(TierInfoLoadingState());
    try {
      final results = await Future.wait([
        useCase.call(param: userId),
        serviceLocator<WaterPricingUseCase>().call(),
      ]);

      final Either result1 = results[0];
      final Either result2 = results[1];

      // Check both for errors
      String? error1;
      String? error2;
      dynamic tierData;
      dynamic otherData;

      result1.fold((error) => error1 = error, (data) => tierData = data);

      result2.fold((error) => error2 = error, (data) => otherData = data);

      // Handle errors
      if (error1 != null) {
        emit(TierInfoErrorState(errorMessage: error1!));
        return;
      }

      if (error2 != null) {
        emit(TierInfoErrorState(errorMessage: error2!));
        return;
      }

      final List<PumpStationTierInfo> tierList = tierData;
      final WaterPricingResponse waterPricingResponse = otherData;

      // Handle empty tier list as informational state
      if (tierList.isEmpty) {
        emit(TierInfoEmptyState(waterPricingResponse: waterPricingResponse));
        return;
      }

      int selectedIndex = 0;
      if (targetPumpStationId != null) {
        final index = tierList.indexWhere(
          (tier) => tier.pumpStationId == targetPumpStationId,
        );
        if (index != -1) {
          selectedIndex = index;
        }
      }

      emit(
        TierInfoLoadedState(
          tierList: tierList,
          selectedIndex: selectedIndex,
          waterPricingResponse: waterPricingResponse,
        ),
      );
    } catch (e) {
      emit(TierInfoErrorState(errorMessage: e.toString()));
    }
  }

  void selectPumpStation(int index) {
    final currentState = state;
    if (currentState is TierInfoLoadedState) {
      emit(currentState.copyWith(selectedIndex: index));
    }
  }

  void refreshTierInfo({
    required UseCase useCase,
    int? targetPumpStationId,
    int? userId,
  }) {
    loadTierInfo(
      useCase: useCase,
      targetPumpStationId: targetPumpStationId,
      userId: userId,
    );
  }
}
