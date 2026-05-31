// common/bloc/create_pump/office_detail_state.dart

import 'package:demo_app/data/models/pump_station_creation_payload.dart';

abstract class CreatePumpState {}

class CreatePumpInitialState extends CreatePumpState {}

class CreatePumpLoadingState extends CreatePumpState {}

class CreatePumpSuccessState extends CreatePumpState {
  final PumpStationCreationResponse createdStation;

  CreatePumpSuccessState({required this.createdStation});
}

class CreatePumpErrorState extends CreatePumpState {
  final String errorMessage;

  CreatePumpErrorState({required this.errorMessage});
}
