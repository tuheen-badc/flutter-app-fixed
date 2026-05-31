class SignUpPayload {
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final String password;

  SignUpPayload({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dob': dob,
      'password': password,
    };
  }
}
