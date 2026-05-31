// domain/usecases/office_pump_list_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/office_pump_criteria.dart';
import 'package:demo_app/domain/repository/office.dart';
import 'package:demo_app/service_locator.dart';

class OfficePumpListUseCase implements UseCase<Either, OfficePumpCriteria> {
  @override
  Future<Either> call({OfficePumpCriteria? param}) async {
    return serviceLocator<OfficeRepository>().officePumpList(param!);
  }
}
