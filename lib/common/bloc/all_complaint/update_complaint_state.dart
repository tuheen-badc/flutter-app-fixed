// lib/common/bloc/complaint/complaint_update_state.dart

abstract class ComplaintUpdateState {}

class ComplaintUpdateInitialState extends ComplaintUpdateState {}

class ComplaintUpdateLoadingState extends ComplaintUpdateState {
  final int complaintId;

  ComplaintUpdateLoadingState({required this.complaintId});
}

class ComplaintUpdateSuccessState extends ComplaintUpdateState {
  final int complaintId;

  ComplaintUpdateSuccessState({required this.complaintId});
}

class ComplaintUpdateFailureState extends ComplaintUpdateState {
  final String errorMessage;

  ComplaintUpdateFailureState({required this.errorMessage});
}