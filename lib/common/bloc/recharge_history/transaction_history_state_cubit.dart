import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/recharge_history/transaction_history_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit() : super(TransactionHistoryInitialState());

  void loadTransactionHistory({
    required UseCase useCase,
    dynamic params,
  }) async {
    emit(TransactionHistoryLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(TransactionHistoryErrorState(errorMessage: error));
        },
        (data) {
          // Parse the response data
          emit(
            TransactionHistoryLoadedState(
              historyList: data.historyList,
              totalElements: data.totalElements,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(TransactionHistoryErrorState(errorMessage: e.toString()));
    }
  }

  void refreshHistory({required UseCase useCase, dynamic params}) {
    loadTransactionHistory(useCase: useCase, params: params);
  }
}
