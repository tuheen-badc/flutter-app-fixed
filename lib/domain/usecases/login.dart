import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';

class LoginUseCase implements UseCase<Either, LoginPayload> {
  @override
  Future<Either> call({LoginPayload? param}) async {
    return serviceLocator<AuthRepository>().login(param!);
  }
}
