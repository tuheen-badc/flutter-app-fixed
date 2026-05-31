import 'package:demo_app/data/models/user_tier_list.dart';

import '../../data/models/credit_info.dart';
import '../../data/models/user_info.dart';

abstract class RoleSpecificData {
  final User userInfo;

  RoleSpecificData({required this.userInfo});
}

class UserRolData extends RoleSpecificData {
  final UserCreditResponseModel creditInfo;


  UserRolData({
    required super.userInfo,
    required this.creditInfo
  });
}

class AdminRoleData extends RoleSpecificData {
  AdminRoleData({required super.userInfo});
}

class SuperAdminRoleData extends RoleSpecificData {
  SuperAdminRoleData({required super.userInfo});
}
