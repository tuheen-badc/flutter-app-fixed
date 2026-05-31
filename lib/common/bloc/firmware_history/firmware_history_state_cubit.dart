// firmware_history_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/firmware_history/firmware_history_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirmwareHistoryCubit extends Cubit<FirmwareHistoryState> {
  FirmwareHistoryCubit() : super(FirmwareHistoryInitialState());

  void loadFirmwareHistory({required UseCase useCase}) async {
    emit(FirmwareHistoryLoadingState());
    try {
      Either result = await useCase.call();
      result.fold(
        (error) {
          emit(FirmwareHistoryErrorState(errorMessage: error));
        },
        (data) {
          emit(FirmwareHistoryLoadedState(historyList: data.items));
        },
      );
    } catch (e) {
      emit(FirmwareHistoryErrorState(errorMessage: e.toString()));
    }
  }
}
