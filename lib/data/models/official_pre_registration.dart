// official_pre_registration.dart
class OfficialPreRegistrationResponse {
  final List<OfficialPreRegistrationItem> registrationList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficialPreRegistrationResponse({
    required this.registrationList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OfficialPreRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return OfficialPreRegistrationResponse(
      registrationList:
          (json['_embedded']['preRegistrationResponseModelList']
                  as List)
              .map((item) => OfficialPreRegistrationItem.fromJson(item))
              .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class OfficialPreRegistrationItem {
  final int id;
  final String name;
  final String phone;
  final String registrationRole;
  final bool pending;

  OfficialPreRegistrationItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.registrationRole,
    required this.pending,
  });

  factory OfficialPreRegistrationItem.fromJson(Map<String, dynamic> json) {
    return OfficialPreRegistrationItem(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      registrationRole: json['registrationRole'],
      pending: json['pending'],
    );
  }

  OfficialPreRegistrationItem copyWith({
    int? id,
    String? name,
    String? phone,
    String? registrationRole,
    bool? pending,
  }) {
    return OfficialPreRegistrationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      registrationRole: registrationRole ?? this.registrationRole,
      pending: pending ?? this.pending,
    );
  }
}
