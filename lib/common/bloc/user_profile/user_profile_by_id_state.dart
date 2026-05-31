// user_profile_state.dart
import '../../../data/models/user_info.dart';

abstract class UserProfileState {}

class UserProfileInitialState extends UserProfileState {}

class UserProfileLoadingState extends UserProfileState {}

class UserProfileLoadedState extends UserProfileState {
  final User user;

  UserProfileLoadedState({required this.user});

  UserProfileLoadedState copyWith({User? user}) {
    return UserProfileLoadedState(user: user ?? this.user);
  }
}

class UserProfileErrorState extends UserProfileState {
  final String errorMessage;

  UserProfileErrorState({required this.errorMessage});
}
