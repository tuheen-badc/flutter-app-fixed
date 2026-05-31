// common/bloc/create_pump/office_detail_state.dart

import '../../../data/models/office_detail_model.dart';

abstract class OfficeDetailViewState {}

class OfficeDetailViewInitialState extends OfficeDetailViewState {}

class OfficeDetailViewLoadingState extends OfficeDetailViewState {}

class OfficeDetailViewLoadedState extends OfficeDetailViewState {
  final OfficeDetail detail;

  OfficeDetailViewLoadedState({required this.detail});

  OfficeDetailViewLoadedState copyWith({OfficeDetail? detail}) =>
      OfficeDetailViewLoadedState(detail: detail ?? this.detail);
}

class OfficeDetailViewErrorState extends OfficeDetailViewState {
  final String errorMessage;

  OfficeDetailViewErrorState({required this.errorMessage});
}
