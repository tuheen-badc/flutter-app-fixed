// data/models/office_pump_response.dart
class OfficePumpResponse {
  final List<OfficePumpItem> pumpList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficePumpResponse({
    required this.pumpList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OfficePumpResponse.fromJson(Map<String, dynamic> json) {
    return OfficePumpResponse(
      pumpList: (json['_embedded']['pumpStationDtoList'] as List)
          .map((item) => OfficePumpItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class OfficePumpItem {
  final int id;
  final String name;
  final String divisionName;
  final String districtName;
  final String upazillaName;
  final String unionName;

  OfficePumpItem({
    required this.id,
    required this.name,
    required this.divisionName,
    required this.districtName,
    required this.upazillaName,
    required this.unionName,
  });

  String get locationSummary => [
    divisionName,
    districtName,
    upazillaName,
    unionName,
  ].where((s) => s.isNotEmpty).join(', ');

  factory OfficePumpItem.fromJson(Map<String, dynamic> json) {
    return OfficePumpItem(
      id: json['id'],
      name: json['name'] ?? '',
      divisionName: json['divisionName'] ?? '',
      districtName: json['districtName'] ?? '',
      upazillaName: json['upazillaName'] ?? '',
      unionName: json['unionName'] ?? '',
    );
  }
}
