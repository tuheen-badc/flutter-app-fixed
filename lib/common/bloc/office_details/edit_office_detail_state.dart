// common/bloc/create_pump/office_detail_state.dart

import '../../../data/models/office_detail_model.dart';

abstract class OfficeDetailEditState {}

class OfficeDetailEditInitialState extends OfficeDetailEditState {}

class OfficeDetailEditLoadingState extends OfficeDetailEditState {}

class OfficeDetailEditSuccessState extends OfficeDetailEditState {
  final OfficeDetail updatedDetail;

  OfficeDetailEditSuccessState({required this.updatedDetail});
}

class OfficeDetailEditErrorState extends OfficeDetailEditState {
  final String errorMessage;

  OfficeDetailEditErrorState({required this.errorMessage});
}
