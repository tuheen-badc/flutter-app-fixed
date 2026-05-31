// official_pre_registration_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/official_pre_registration_criteria.dart';
import 'package:demo_app/domain/repository/pre_registration.dart';
import 'package:demo_app/service_locator.dart';

class OfficialPreRegistrationUseCase
    implements UseCase<Either, OfficialPreRegistrationCriteria> {
  @override
  Future<Either> call({OfficialPreRegistrationCriteria? param}) async {
    return serviceLocator<PreRegistrationRepository>().allPreRegistration(
      param!,
    );
  }
}
