// data/models/office_user_list_criteria.dart
import 'package:demo_app/data/models/user_info.dart';

class OfficeUserListCriteria {
  final int officeId;
  final int page;
  final int size;
  final UserRole role;
  final bool? blocked;
  final String? phone;

  OfficeUserListCriteria({
    required this.officeId,
    this.page = 0,
    this.size = 20,
    required this.role,
    this.blocked,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'page': page,
      'size': size,
      'role': role.name,
    };
    if (blocked != null) map['blocked'] = blocked;
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    return map;
  }
}
