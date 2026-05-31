// electricity_status_history.dart

class ElectricityStatusHistoryResponse {
  final List<ElectricityStatusHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ElectricityStatusHistoryResponse({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory ElectricityStatusHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ElectricityStatusHistoryResponse(
      historyList:
          (json['_embedded']['electricityStatusHistoryModelList'] as List)
              .map((item) => ElectricityStatusHistoryItem.fromJson(item))
              .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class ElectricityStatusHistoryItem {
  final DateTime loggedAt;
  final bool phaseOneAvailable;
  final bool phaseTwoAvailable;
  final bool phaseThreeAvailable;

  ElectricityStatusHistoryItem({
    required this.loggedAt,
    required this.phaseOneAvailable,
    required this.phaseTwoAvailable,
    required this.phaseThreeAvailable,
  });

  factory ElectricityStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return ElectricityStatusHistoryItem(
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      phaseOneAvailable: json['phaseOneAvailable'] as bool,
      phaseTwoAvailable: json['phaseTwoAvailable'] as bool,
      phaseThreeAvailable: json['phaseThreeAvailable'] as bool,
    );
  }

  /// Returns how many of the three phases are available.
  int get availablePhaseCount => [
    phaseOneAvailable,
    phaseTwoAvailable,
    phaseThreeAvailable,
  ].where((v) => v).length;

  /// Convenience: true when all three phases are present.
  bool get isFullPower =>
      phaseOneAvailable && phaseTwoAvailable && phaseThreeAvailable;

  /// Convenience: true when no phase is available.
  bool get isNoPower =>
      !phaseOneAvailable && !phaseTwoAvailable && !phaseThreeAvailable;
}
