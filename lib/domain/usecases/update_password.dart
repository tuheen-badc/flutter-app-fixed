import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UpdatePasswordUseCase implements UseCase<Either, UpdatePasswordPayload> {
  @override
  Future<Either> call({UpdatePasswordPayload? param}) async {
    return serviceLocator<UserRepository>().updatePassword(param!);
  }
}
