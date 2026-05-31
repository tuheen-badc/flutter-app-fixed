// recharge_history_response.dart
import 'package:demo_app/data/models/transaction.dart';

// Response model for API
class RechargeHistoryResponse {
  final List<TransactionHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  RechargeHistoryResponse({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory RechargeHistoryResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>;
    final historyListJson = embedded['userTransactionHistoryModelList'] as List;
    final page = json['page'] as Map<String, dynamic>;

    return RechargeHistoryResponse(
      historyList: historyListJson
          .map((item) => TransactionHistoryItem.fromJson(item))
          .toList(),
      totalElements: page['totalElements'] as int,
      totalPages: page['totalPages'] as int,
      currentPage: page['number'] as int,
    );
  }
}
