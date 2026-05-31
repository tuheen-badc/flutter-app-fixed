// common/bloc/pump_detail_edit/pump_detail_edit_state.dart
import '../../../data/models/pump_station_detail.dart';

abstract class PumpDetailEditState {}

class PumpDetailEditInitialState extends PumpDetailEditState {}

class PumpDetailEditLoadingState extends PumpDetailEditState {}

class PumpDetailEditSuccessState extends PumpDetailEditState {
  /// The freshly updated detail returned by the backend after the edit.
  final PumpStationDetailView updatedDetail;

  PumpDetailEditSuccessState({required this.updatedDetail});
}

class PumpDetailEditErrorState extends PumpDetailEditState {
  final String errorMessage;

  PumpDetailEditErrorState({required this.errorMessage});
}
