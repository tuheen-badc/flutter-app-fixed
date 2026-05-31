// common/bloc/pump_detail_view/pump_detail_view_state.dart
import '../../../data/models/pump_station_detail.dart';

abstract class PumpDetailViewState {}

class PumpDetailViewInitialState extends PumpDetailViewState {}

class PumpDetailViewLoadingState extends PumpDetailViewState {}

class PumpDetailViewLoadedState extends PumpDetailViewState {
  final PumpStationDetailView detail;

  PumpDetailViewLoadedState({required this.detail});

  PumpDetailViewLoadedState copyWith({PumpStationDetailView? detail}) {
    return PumpDetailViewLoadedState(detail: detail ?? this.detail);
  }
}

class PumpDetailViewErrorState extends PumpDetailViewState {
  final String errorMessage;

  PumpDetailViewErrorState({required this.errorMessage});
}
