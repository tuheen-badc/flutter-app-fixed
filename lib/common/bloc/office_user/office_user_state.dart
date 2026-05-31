import '../../../data/models/office_user_list_response.dart';

abstract class OfficeUserListState {}

class OfficeUserListInitialState extends OfficeUserListState {}

class OfficeUserListLoadingState extends OfficeUserListState {}

class OfficeUserListLoadedState extends OfficeUserListState {
  final List<OfficeUserItem> userList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficeUserListLoadedState({
    required this.userList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });
}

class OfficeUserListErrorState extends OfficeUserListState {
  final String errorMessage;

  OfficeUserListErrorState({required this.errorMessage});
}
