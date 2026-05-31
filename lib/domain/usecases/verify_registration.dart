import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';

class VerifyRegistrationUseCase implements UseCase<Either, VerifyOtpPayload> {
  @override
  Future<Either> call({VerifyOtpPayload? param}) async {
    return serviceLocator<AuthRepository>().verifyOtpForRegistration(param!);
  }
}
