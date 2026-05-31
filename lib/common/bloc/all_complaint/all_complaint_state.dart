// lib/common/bloc/complaint/complaint_list_state.dart

import '../../../data/models/complaint.dart';

abstract class ComplaintListState {}

class ComplaintListInitialState extends ComplaintListState {}

class ComplaintListLoadingState extends ComplaintListState {}

class ComplaintListLoadedState extends ComplaintListState {
  final List<ComplaintItem> complaints;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ComplaintListLoadedState({
    required this.complaints,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class ComplaintListErrorState extends ComplaintListState {
  final String errorMessage;

  ComplaintListErrorState({required this.errorMessage});
}
