class UpdateNamePayload {
  final String firstName;
  final String lastName;

  UpdateNamePayload({required this.firstName, required this.lastName});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'firstName': firstName, 'lastName': lastName};
  }
}
