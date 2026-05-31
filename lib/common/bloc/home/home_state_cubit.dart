import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/home/home_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/usecases/user_credit.dart';
import 'package:demo_app/domain/usecases/user_info.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../domain/entities/role_specific_data.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitialState());

  void loadHomeData() async {
    emit(HomeLoadingState());
    //await Future.delayed(const Duration(milliseconds: 500));
    try {
      UseCase getUserInfoUseCase = serviceLocator<UserInfoUseCase>();
      Either userResult = await getUserInfoUseCase.call();

      await userResult.fold(
        (error) {
          emit(HomeErrorState(errorMessage: error.toString()));
        },
        (userData) async {
          if (userData.role == UserRole.USER) {
            await _loadUserData(userData);
          } else if (userData.role == UserRole.ADMIN) {
            await _loadAdminData(userData);
          } else if (userData.role == UserRole.SUPER_ADMIN) {
            await _loadSuperAdminData(userData);
          }
        },
      );
    } catch (e) {
      emit(HomeErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _loadUserData(User userData) async {
    try {
      final List<Future<Either>> futures = [
        serviceLocator<UserCreditUseCase>().call(),
      ];

      final results = await Future.wait(futures);
      final creditInfo = results[0];

      // Check if any call failed
      final failedResults = results.where((result) => result.isLeft()).toList();
      if (failedResults.isNotEmpty) {
        final errorMessage = failedResults.first.fold(
          (error) => error.toString(),
          (_) => '',
        );
        emit(HomeErrorState(errorMessage: errorMessage));
        return;
      }

      final creditInfoResponse = creditInfo.getOrElse(() => null);

      final superAdminData = UserRolData(
        userInfo: userData,
        creditInfo: creditInfoResponse,
      );

      emit(HomeLoadedState(userInfo: userData, roleData: superAdminData));
    } catch (e) {
      emit(HomeErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _loadAdminData(User userData) async {
    try {
      final adminData = AdminRoleData(userInfo: userData);
      emit(HomeLoadedState(userInfo: userData, roleData: adminData));
    } catch (e) {
      emit(HomeErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _loadSuperAdminData(User userData) async {
    try {
      final superAdminData = SuperAdminRoleData(userInfo: userData);
      emit(HomeLoadedState(userInfo: userData, roleData: superAdminData));
    } catch (e) {
      emit(HomeErrorState(errorMessage: e.toString()));
    }
  }
}
