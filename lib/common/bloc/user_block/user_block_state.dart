// user_block_state.dart
abstract class UserBlockState {}

class UserBlockInitialState extends UserBlockState {}

class UserBlockLoadingState extends UserBlockState {
  final int userId;

  UserBlockLoadingState({required this.userId});
}

class UserBlockSuccessState extends UserBlockState {
  final int userId;
  final bool blocked;
  final String message;

  UserBlockSuccessState({
    required this.userId,
    required this.blocked,
    required this.message,
  });
}

class UserBlockFailureState extends UserBlockState {
  final int userId;
  final String errorMessage;

  UserBlockFailureState({required this.userId, required this.errorMessage});
}
