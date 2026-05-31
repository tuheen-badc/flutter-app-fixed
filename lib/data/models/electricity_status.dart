class ElectricityAvailabilityIndicator {
  final String name;
  final String divisionName;
  final String districtName;
  final String upazillaName;
  final String unionName;
  final DateTime lastUpdatedAt;
  final bool phaseOneAvailable;
  final bool phaseTwoAvailable;
  final bool phaseThreeAvailable;

  ElectricityAvailabilityIndicator({
    required this.name,
    required this.divisionName,
    required this.districtName,
    required this.upazillaName,
    required this.unionName,
    required this.lastUpdatedAt,
    required this.phaseOneAvailable,
    required this.phaseTwoAvailable,
    required this.phaseThreeAvailable,
  });

  factory ElectricityAvailabilityIndicator.fromJson(Map<String, dynamic> json) {
    return ElectricityAvailabilityIndicator(
      name: json['name'] ?? '',
      divisionName: json['divisionName'] ?? '',
      districtName: json['districtName'] ?? '',
      upazillaName: json['upazillaName'] ?? '',
      unionName: json['unionName'] ?? '',
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      phaseOneAvailable: json['phaseOneAvailable'] ?? false,
      phaseTwoAvailable: json['phaseTwoAvailable'] ?? false,
      phaseThreeAvailable: json['phaseThreeAvailable'] ?? false,
    );
  }

  String get location {
    return '$unionName, $upazillaName, $districtName, $divisionName';
  }
}

class ElectricityAvailabilityResponse {
  final List<ElectricityAvailabilityIndicator> indicators;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;

  ElectricityAvailabilityResponse({
    required this.indicators,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
  });

  factory ElectricityAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>?;
    final indicatorList =
        embedded?['electricityAvailabilityIndicatorDtoList']
            as List<dynamic>? ??
        [];

    final page = json['page'] as Map<String, dynamic>? ?? {};

    return ElectricityAvailabilityResponse(
      indicators: indicatorList
          .map(
            (item) => ElectricityAvailabilityIndicator.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      totalElements: page['totalElements'] ?? 0,
      totalPages: page['totalPages'] ?? 0,
      currentPage: page['number'] ?? 0,
      size: page['size'] ?? 20,
    );
  }
}
