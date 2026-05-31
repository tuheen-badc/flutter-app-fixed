// official_pre_registration_delete_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/pre_registration.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/pre_registration_deletion_param.dart';

class OfficialPreRegistrationDeleteUseCase
    implements UseCase<Either, PreRegistrationDeletionParam> {
  @override
  Future<Either> call({PreRegistrationDeletionParam? param}) async {
    return serviceLocator<PreRegistrationRepository>().deletePreRegistration(
      param!,
    );
  }
}
