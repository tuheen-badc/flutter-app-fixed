// user_list.dart
class UserListResponse {
  final List<UserItem> userList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  UserListResponse({
    required this.userList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      userList: (json['_embedded']['userDtoList'] as List)
          .map((item) => UserItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class UserItem {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final bool blocked;
  final String officeName;

  UserItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.blocked,
    required this.officeName,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: json['role'],
      blocked: json['blocked'],
      officeName: json['officeName'],
    );
  }

  String get fullName => '$firstName $lastName';

  UserItem copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    bool? blocked,
    String? officeName,
  }) {
    return UserItem(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      blocked: blocked ?? this.blocked,
      officeName: officeName ?? this.officeName,
    );
  }
}
