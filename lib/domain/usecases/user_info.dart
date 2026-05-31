import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UserInfoUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<UserRepository>().userInfo();
  }
}
