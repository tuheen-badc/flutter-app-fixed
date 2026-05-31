class OfficeCreationPayload {
  final String name;
  final int divisionId;
  final int districtId;
  final int? upazillaId;
  final int? unionId;
  final String? contactNumber;

  OfficeCreationPayload({
    required this.name,
    required this.divisionId,
    required this.districtId,
    this.upazillaId,
    this.unionId,
    this.contactNumber,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'divisionId': divisionId,
      'districtId': districtId,
    };

    if (upazillaId != null) map['upazillaId'] = upazillaId;
    if (unionId != null) map['unionId'] = unionId;
    if (contactNumber != null && contactNumber!.isNotEmpty) {
      map['contactNumber'] = contactNumber;
    }

    return map;
  }
}
