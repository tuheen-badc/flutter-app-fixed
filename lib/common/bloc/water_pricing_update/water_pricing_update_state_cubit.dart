// update_water_pricing_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/water_pricing_update/water_pricing_update_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateWaterPricingCubit extends Cubit<UpdateWaterPricingState> {
  UpdateWaterPricingCubit() : super(UpdateWaterPricingInitialState());

  void updateWaterPricing({required UseCase useCase, dynamic params}) async {
    emit(UpdateWaterPricingLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdateWaterPricingErrorState(errorMessage: error));
        },
        (data) {
          emit(
            UpdateWaterPricingSuccessState(
              message: 'Water pricing updated successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(UpdateWaterPricingErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() {
    emit(UpdateWaterPricingInitialState());
  }
}
