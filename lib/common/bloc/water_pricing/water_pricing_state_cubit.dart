import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/water_pricing/water_pricing_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaterPricingCubit extends Cubit<WaterPricingState> {
  WaterPricingCubit() : super(WaterPricingInitialState());

  void execute({dynamic params, required UseCase useCase}) async {
    emit(WaterPricingLoadingState());

    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(WaterPricingErrorState(errorMessage: error.toString()));
        },
        (data) {
          emit(WaterPricingLoadedState(pricing: data));
        },
      );
    } catch (e) {
      emit(
        WaterPricingErrorState(
          errorMessage: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  void refresh({dynamic params, required UseCase useCase}) async {
    execute(params: params, useCase: useCase);
  }
}
