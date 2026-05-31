// office_response.dart
class OfficeResponse {
  final List<OfficeItem> officeList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OfficeResponse({
    required this.officeList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OfficeResponse.fromJson(Map<String, dynamic> json) {
    return OfficeResponse(
      officeList: (json['_embedded']['officeDtoList'] as List)
          .map((item) => OfficeItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}

class OfficeItem {
  final int id;
  final String name;
  final String divisionName;
  final String districtName;
  final String upazillaName;
  final String unionName;

  OfficeItem({
    required this.id,
    required this.name,
    required this.divisionName,
    required this.districtName,
    required this.upazillaName,
    required this.unionName,
  });

  factory OfficeItem.fromJson(Map<String, dynamic> json) {
    return OfficeItem(
      id: json['id'],
      name: json['name'],
      divisionName: json['divisionName'] ?? '',
      districtName: json['districtName'] ?? '',
      upazillaName: json['upazillaName'] ?? '',
      unionName: json['unionName'] ?? '',
    );
  }
}
