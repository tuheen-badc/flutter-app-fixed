import 'package:demo_app/data/models/pump_station_history.dart';

// Response model for API
class PumpStationHistoryResponse {
  final List<PumpStationHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PumpStationHistoryResponse({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PumpStationHistoryResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>;
    final historyListJson = embedded['waterSupplyHistoryDtoList'] as List;
    final page = json['page'] as Map<String, dynamic>;

    return PumpStationHistoryResponse(
      historyList: historyListJson
          .map((item) => PumpStationHistoryItem.fromJson(item))
          .toList(),
      totalElements: page['totalElements'] as int,
      totalPages: page['totalPages'] as int,
      currentPage: page['number'] as int,
    );
  }
}
