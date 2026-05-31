// office_pump_list_state.dart
import '../../../data/models/office_response.dart';

abstract class AllOfficeState {}

class AllOfficeInitialState extends AllOfficeState {}

class AllOfficeLoadingState extends AllOfficeState {}

class AllOfficeLoadedState extends AllOfficeState {
  final List<OfficeItem> officeList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  AllOfficeLoadedState({
    required this.officeList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class AllOfficeErrorState extends AllOfficeState {
  final String errorMessage;

  AllOfficeErrorState({required this.errorMessage});
}
