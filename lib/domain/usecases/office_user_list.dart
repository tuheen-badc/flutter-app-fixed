// domain/usecases/office_user_list_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/office_user_list_criteria.dart';
import 'package:demo_app/domain/repository/office.dart';
import 'package:demo_app/service_locator.dart';

class OfficeUserListUseCase implements UseCase<Either, OfficeUserListCriteria> {
  @override
  Future<Either> call({OfficeUserListCriteria? param}) async {
    return serviceLocator<OfficeRepository>().officeUserList(param!);
  }
}
