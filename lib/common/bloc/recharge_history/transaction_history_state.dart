// Transaction history screen states
import '../../../data/models/transaction.dart';

abstract class TransactionHistoryState {}

class TransactionHistoryInitialState extends TransactionHistoryState {}

class TransactionHistoryLoadingState extends TransactionHistoryState {}

class TransactionHistoryLoadedState extends TransactionHistoryState {
  final List<TransactionHistoryItem> historyList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  TransactionHistoryLoadedState({
    required this.historyList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class TransactionHistoryErrorState extends TransactionHistoryState {
  final String errorMessage;

  TransactionHistoryErrorState({required this.errorMessage});
}
