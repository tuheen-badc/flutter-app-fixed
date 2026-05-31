import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/water_budget/update_water_budget_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';

class UpdateWaterBudgetScreenCubit extends Cubit<UpdateWaterBudgetScreenState> {
  UpdateWaterBudgetScreenCubit() : super(UpdateWaterBudgetScreenInitialState());

  Future<void> loadWaterBudget({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(UpdateWaterBudgetScreenLoadingState());
    try {
      Either result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(UpdateWaterBudgetScreenFailureState(errorMessage: error));
        },
        (data) {
          // assuming `data` is a WaterBudget model or similar
          emit(
            UpdateWaterBudgetScreenSuccessState(
              budgetId: data.id,
              totalLandArea: data.totalLandArea,
              totalWater: data.totalWater,
            ),
          );
        },
      );
    } catch (e) {
      emit(UpdateWaterBudgetScreenFailureState(errorMessage: e.toString()));
    }
  }

  void updateLocalState({
    required int budgetId,
    required double totalLandArea,
    required double totalWater,
  }) {
    emit(
      UpdateWaterBudgetScreenSuccessState(
        totalLandArea: totalLandArea,
        totalWater: totalWater,
        budgetId: budgetId,
      ),
    );
  }
}

class UpdateWaterBudgetButtonCubit extends Cubit<UpdateWaterBudgetButtonState> {
  UpdateWaterBudgetButtonCubit() : super(UpdateWaterBudgetButtonInitialState());

  Future<void> updateWaterBudget({
    dynamic params,
    required UseCase useCase,
  }) async {
    emit(UpdateWaterBudgetButtonLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(UpdateWaterBudgetButtonFailureState(errorMessage: error));
        },
        (data) {
          emit(UpdateWaterBudgetButtonSuccessState());
        },
      );
    } catch (e) {
      emit(UpdateWaterBudgetButtonFailureState(errorMessage: e.toString()));
    }
  }
}
