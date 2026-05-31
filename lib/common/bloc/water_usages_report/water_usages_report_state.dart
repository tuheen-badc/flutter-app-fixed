abstract class WaterUsageReportState {}

class WaterUsageReportInitialState extends WaterUsageReportState {}

class WaterUsageReportLoadingState extends WaterUsageReportState {
  final int month;
  final int year;

  WaterUsageReportLoadingState({required this.month, required this.year});
}

class WaterUsageReportSuccessState extends WaterUsageReportState {
  final int month;
  final int year;
  final String fileName;

  WaterUsageReportSuccessState({
    required this.month,
    required this.year,
    required this.fileName,
  });
}

class WaterUsageReportErrorState extends WaterUsageReportState {
  final String errorMessage;

  WaterUsageReportErrorState({required this.errorMessage});
}