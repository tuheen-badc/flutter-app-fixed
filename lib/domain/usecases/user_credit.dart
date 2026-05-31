import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/signup_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/domain/repository/credit.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UserCreditUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic param}) async {
    return serviceLocator<CreditRepository>().userCreditInfo();
  }
}
