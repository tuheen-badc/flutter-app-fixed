import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/signup_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';

class SignUpUseCase implements UseCase<Either, SignUpPayload> {
  @override
  Future<Either> call({SignUpPayload? param}) async {
    return serviceLocator<AuthRepository>().signup(param!);
  }
}

