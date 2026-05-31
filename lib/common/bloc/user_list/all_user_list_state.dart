// user_block_state.dart
import '../../../data/models/user_list_response.dart';

abstract class AllUserListState {}

class AllUserListInitialState extends AllUserListState {}

class AllUserListLoadingState extends AllUserListState {}

class AllUserListLoadedState extends AllUserListState {
  final List<UserItem> userList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  AllUserListLoadedState({
    required this.userList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  AllUserListLoadedState copyWith({
    List<UserItem>? userList,
    int? totalElements,
    int? totalPages,
    int? currentPage,
  }) {
    return AllUserListLoadedState(
      userList: userList ?? this.userList,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class AllUserListErrorState extends AllUserListState {
  final String errorMessage;

  AllUserListErrorState({required this.errorMessage});
}