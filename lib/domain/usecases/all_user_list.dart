// all_user_list_usecase.dart

import 'package:dartz/dartz.dart';

import '../../core/usecase/usecase.dart';
import '../../data/models/user_list_criteria.dart';
import '../../service_locator.dart';
import '../repository/user.dart';

class AllUserListUseCase implements UseCase<Either, UserListCriteria> {
  @override
  Future<Either> call({UserListCriteria? param}) async {
    return serviceLocator<UserRepository>().allUserList(param!);
  }
}
