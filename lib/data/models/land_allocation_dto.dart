class LandAllocationDto {
  final int id;
  final String phone;
  final String name;
  final double amountOfLand;

  LandAllocationDto({
    required this.id,
    required this.phone,
    required this.name,
    required this.amountOfLand,
  });

  factory LandAllocationDto.fromJson(Map<String, dynamic> json) {
    return LandAllocationDto(
      id: json['id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String,
      amountOfLand: (json['amountOfLand'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'amountOfLand': amountOfLand,
    };
  }
}
