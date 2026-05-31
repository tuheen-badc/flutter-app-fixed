class OfficeCreationResponse {
  final int id;
  final String name;
  final DateTime createdAt;

  OfficeCreationResponse({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory OfficeCreationResponse.fromJson(Map<String, dynamic> json) {
    return OfficeCreationResponse(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
