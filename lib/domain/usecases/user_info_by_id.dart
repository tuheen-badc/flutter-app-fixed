import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UserInfoByIdUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<UserRepository>().userInfoById(param!);
  }
}
