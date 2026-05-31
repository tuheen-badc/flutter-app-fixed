import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/office_creation_payload.dart';
import 'package:demo_app/service_locator.dart';

import '../repository/office.dart';

class CreateOfficeUseCase implements UseCase<Either, OfficeCreationPayload> {
  @override
  Future<Either> call({OfficeCreationPayload? param}) async {
    return serviceLocator<OfficeRepository>().createOffice(param!);
  }
}
