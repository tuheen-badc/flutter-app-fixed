import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class VerifyPhoneUpdateUseCase implements UseCase<Either, VerifyOtpPayload> {
  @override
  Future<Either> call({VerifyOtpPayload? param}) async {
    return serviceLocator<UserRepository>().verifyPhoneUpdateOTP(param!);
  }
}
