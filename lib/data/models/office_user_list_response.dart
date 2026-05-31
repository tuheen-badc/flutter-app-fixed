// data/models/office_user_list_response.dart
class OfficeUserListResponse {
  final List<OfficeUserItem> userList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficeUserListResponse({
    required this.userList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OfficeUserListResponse.fromJson(Map<String, dynamic> json) {
    return OfficeUserListResponse(
      userList: (json['_embedded']['userDtoList'] as List)
          .map((item) => OfficeUserItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class OfficeUserItem {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String role;
  final bool blocked;
  final String? officeName;

  OfficeUserItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.role,
    required this.blocked,
    this.officeName,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory OfficeUserItem.fromJson(Map<String, dynamic> json) {
    return OfficeUserItem(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? '',
      blocked: json['blocked'] ?? false,
      officeName: json['officeName'],
    );
  }
}
