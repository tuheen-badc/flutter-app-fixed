// user_block_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/user_block_payload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

class UserBlockUseCase implements UseCase<Either, UserBlockPayload> {
  @override
  Future<Either> call({UserBlockPayload? param}) async {
    return serviceLocator<UserRepository>().updateBlockingStatus(param!);
  }
}
