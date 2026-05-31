// official_pre_registration_payload.dart
class OfficialPreRegistrationPayload {
  final String name;
  final String phone;
  final String registrationRole;
  final int officeId;

  OfficialPreRegistrationPayload({
    required this.name,
    required this.phone,
    required this.registrationRole,
    required this.officeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'registrationRole': registrationRole,
      'officeId': officeId,
    };
  }
}
