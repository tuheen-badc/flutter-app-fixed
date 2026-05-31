// reset_password_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/reset_password_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';

class ResetPasswordUseCase implements UseCase<Either, ResetPasswordPayload> {
  @override
  Future<Either> call({ResetPasswordPayload? param}) async {
    return serviceLocator<AuthRepository>().resetPassword(param!);
  }
}
