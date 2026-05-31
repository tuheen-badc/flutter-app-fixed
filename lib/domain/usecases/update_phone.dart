import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UpdatePhoneUseCase implements UseCase<Either, UpdatePhonePayload> {
  @override
  Future<Either> call({UpdatePhonePayload? param}) async {
    return serviceLocator<UserRepository>().updatePhone(param!);
  }
}
