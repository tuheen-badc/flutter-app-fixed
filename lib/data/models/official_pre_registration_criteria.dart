// official_pre_registration_criteria.dart
import 'package:demo_app/data/models/user_info.dart';

class OfficialPreRegistrationCriteria {
  final int page;
  final int size;
  final int officeId;
  final UserRole preRegistrationRole;
  final String? phone;

  OfficialPreRegistrationCriteria({
    required this.page,
    required this.size,
    required this.officeId,
    required this.preRegistrationRole,
    this.phone,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'officeId': officeId,
      'preRegistrationRole': preRegistrationRole.name,
    };

    if (phone != null && phone!.isNotEmpty) params['phone'] = phone;

    print(params);

    return params;
  }
}
