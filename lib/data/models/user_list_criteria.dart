// user_list_criteria.dart
import 'package:demo_app/data/models/user_info.dart';

class UserListCriteria {
  final int page;
  final int size;
  final UserRole role;
  final bool? blocked;
  final String? phone;

  UserListCriteria({
    required this.role,
    required this.page,
    required this.size,

    this.blocked,
    this.phone,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'role': role.name,
    };

    if (blocked != null) params['blocked'] = blocked;
    if (phone != null && phone!.isNotEmpty) params['phone'] = phone;

    return params;
  }
}
