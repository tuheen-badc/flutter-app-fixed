abstract class ComplaintState {}

class ComplaintInitialState extends ComplaintState {}

class ComplaintSubmittingState extends ComplaintState {}

class ComplaintSubmittedState extends ComplaintState {
  final String message;

  ComplaintSubmittedState({required this.message});
}

class ComplaintErrorState extends ComplaintState {
  final String errorMessage;

  ComplaintErrorState({required this.errorMessage});
}