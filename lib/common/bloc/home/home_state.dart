import '../../../data/models/user_info.dart';
import '../../../domain/entities/role_specific_data.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final User userInfo;
  final RoleSpecificData? roleData;

  HomeLoadedState({required this.userInfo, required this.roleData});
}

class HomeErrorState extends HomeState {
  final String errorMessage;

  HomeErrorState({required this.errorMessage});
}
