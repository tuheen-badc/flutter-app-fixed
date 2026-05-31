// all_office_list_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/office_fetch_criteria.dart';
import '../repository/office.dart';

class AllOfficeListUseCase implements UseCase<Either, OfficeCriteria> {
  @override
  Future<Either> call({OfficeCriteria? param}) async {
    return serviceLocator<OfficeRepository>().allOfficeList(param!);
  }
}
