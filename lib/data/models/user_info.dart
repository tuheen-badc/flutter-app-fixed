enum UserRole { SUPER_ADMIN, ADMIN, USER }

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole role;
  final bool blocked;
  final int? officeId;
  final String? officeName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.blocked,
    this.officeId,
    this.officeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: UserRole.values.byName(json['role']),
      blocked: json['blocked'],
      officeId: json['officeId'],
      officeName: json['officeName'],
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isSuperAdmin => role == UserRole.SUPER_ADMIN;

  bool get isAdmin => role == UserRole.ADMIN;

  bool get isUser => role == UserRole.USER;
}
