// common/bloc/office_pump_list/office_pump_list_state.dart
import '../../../data/models/office_pump_response.dart';

abstract class OfficePumpListState {}

class OfficePumpListInitialState extends OfficePumpListState {}

class OfficePumpListLoadingState extends OfficePumpListState {}

class OfficePumpListLoadedState extends OfficePumpListState {
  final List<OfficePumpItem> pumpList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficePumpListLoadedState({
    required this.pumpList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class OfficePumpListErrorState extends OfficePumpListState {
  final String errorMessage;
  OfficePumpListErrorState({required this.errorMessage});
}