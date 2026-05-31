import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UpdateNameUseCase implements UseCase<Either, UpdateNamePayload> {
  @override
  Future<Either> call({UpdateNamePayload? param}) async {
    return serviceLocator<UserRepository>().updateName(param!);
  }
}
