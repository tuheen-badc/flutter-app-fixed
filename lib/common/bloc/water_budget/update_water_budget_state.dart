abstract class UpdateWaterBudgetScreenState {}

class UpdateWaterBudgetScreenInitialState
    extends UpdateWaterBudgetScreenState {}

class UpdateWaterBudgetScreenLoadingState
    extends UpdateWaterBudgetScreenState {}

class UpdateWaterBudgetScreenSuccessState extends UpdateWaterBudgetScreenState {
  final int budgetId;
  final double totalLandArea;
  final double totalWater;

  UpdateWaterBudgetScreenSuccessState({
    required this.budgetId,
    required this.totalLandArea,
    required this.totalWater,
  });
}

class UpdateWaterBudgetScreenFailureState extends UpdateWaterBudgetScreenState {
  final String errorMessage;

  UpdateWaterBudgetScreenFailureState({required this.errorMessage});
}

abstract class UpdateWaterBudgetButtonState {}

class UpdateWaterBudgetButtonInitialState
    extends UpdateWaterBudgetButtonState {}

class UpdateWaterBudgetButtonLoadingState
    extends UpdateWaterBudgetButtonState {}

class UpdateWaterBudgetButtonSuccessState
    extends UpdateWaterBudgetButtonState {}

class UpdateWaterBudgetButtonFailureState extends UpdateWaterBudgetButtonState {
  final String errorMessage;

  UpdateWaterBudgetButtonFailureState({required this.errorMessage});
}
