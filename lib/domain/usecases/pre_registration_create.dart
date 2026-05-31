// official_pre_registration_create_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/official_pre_registration_payload.dart';
import 'package:demo_app/domain/repository/pre_registration.dart';
import 'package:demo_app/service_locator.dart';

class OfficialPreRegistrationCreateUseCase
    implements UseCase<Either, OfficialPreRegistrationPayload> {
  @override
  Future<Either> call({OfficialPreRegistrationPayload? param}) async {
    return serviceLocator<PreRegistrationRepository>().createPreRegistration(
      param!,
    );
  }
}
