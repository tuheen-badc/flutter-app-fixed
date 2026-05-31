// domain/usecases/office_detail_use_cases.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/office_detail_model.dart';
import '../repository/office.dart';

class GetOfficeDetailUseCase implements UseCase<Either, int> {
  @override
  Future<Either> call({int? param}) async {
    return serviceLocator<OfficeRepository>().getOfficeDetail(param!);
  }
}

class UpdateOfficeLocationUseCase
    implements UseCase<Either, UpdateOfficeLocationPayload> {
  @override
  Future<Either> call({UpdateOfficeLocationPayload? param}) async {
    return serviceLocator<OfficeRepository>().updateOfficeLocation(param!);
  }
}

class UpdateOfficeContactUseCase
    implements UseCase<Either, UpdateOfficeContactPayload> {
  @override
  Future<Either> call({UpdateOfficeContactPayload? param}) async {
    return serviceLocator<OfficeRepository>().updateOfficeContact(param!);
  }
}
