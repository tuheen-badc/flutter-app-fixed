class PumpStationBasicDto {
  final int? id; // Make id nullable
  final String name;

  PumpStationBasicDto({this.id, required this.name});

  factory PumpStationBasicDto.fromJson(Map<String, dynamic> json) {
    return PumpStationBasicDto(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }
}
