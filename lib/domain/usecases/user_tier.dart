import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/user_tier.dart';
import 'package:demo_app/service_locator.dart';

class UserTierUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<UserTierRepository>().getUserTier(param);
  }
}
