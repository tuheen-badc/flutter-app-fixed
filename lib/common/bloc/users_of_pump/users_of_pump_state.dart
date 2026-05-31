import '../../../data/models/user_of_pump_station_response.dart';

abstract class PumpUsersState {}

class PumpUsersInitialState extends PumpUsersState {}

class PumpUsersLoadingState extends PumpUsersState {}

class PumpUsersLoadedState extends PumpUsersState {
  final List<PumpUserDto> userList;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  PumpUsersLoadedState({
    required this.userList,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

class PumpUsersErrorState extends PumpUsersState {
  final String errorMessage;

  PumpUsersErrorState({required this.errorMessage});
}
