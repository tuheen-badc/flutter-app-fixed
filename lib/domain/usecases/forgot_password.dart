import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/forgot_password_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';

class ForgotPasswordUseCase implements UseCase<Either, ForgotPasswordPayload> {
  @override
  Future<Either> call({ForgotPasswordPayload? param}) async {
    return serviceLocator<AuthRepository>().forgotPassword(param!);
  }
}
