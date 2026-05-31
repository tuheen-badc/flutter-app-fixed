// data/models/office_detail.dart

class OfficeDetail {
  final int id;
  final String name;
  final int divisionId;
  final String divisionName;
  final int districtId;
  final String districtName;
  final int? upazillaId;
  final String? upazillaName;
  final int? unionId;
  final String? unionName;
  final DateTime createdAt;
  final String? contactNumber;

  const OfficeDetail({
    required this.id,
    required this.name,
    required this.divisionId,
    required this.divisionName,
    required this.districtId,
    required this.districtName,
    this.upazillaId,
    this.upazillaName,
    this.unionId,
    this.unionName,
    required this.createdAt,
    this.contactNumber,
  });

  factory OfficeDetail.fromJson(Map<String, dynamic> json) {
    return OfficeDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      divisionId: json['divisionId'] as int,
      divisionName: json['divisionName'] as String,
      districtId: json['districtId'] as int,
      districtName: json['districtName'] as String,
      upazillaId: json['upazillaId'] as int?,
      upazillaName: json['upazillaName'] as String?,
      unionId: json['unionId'] as int?,
      unionName: json['unionName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      contactNumber: json['contactNumber'] as String?,
    );
  }

  OfficeDetail copyWith({
    String? name,
    int? divisionId,
    String? divisionName,
    int? districtId,
    String? districtName,
    int? upazillaId,
    String? upazillaName,
    int? unionId,
    String? unionName,
    String? contactNumber,
    bool clearUpazilla = false,
    bool clearUnion = false,
    bool clearContact = false,
  }) {
    return OfficeDetail(
      id: id,
      name: name ?? this.name,
      divisionId: divisionId ?? this.divisionId,
      divisionName: divisionName ?? this.divisionName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      upazillaId: clearUpazilla ? null : (upazillaId ?? this.upazillaId),
      upazillaName: clearUpazilla ? null : (upazillaName ?? this.upazillaName),
      unionId: clearUnion ? null : (unionId ?? this.unionId),
      unionName: clearUnion ? null : (unionName ?? this.unionName),
      createdAt: createdAt,
      contactNumber: clearContact
          ? null
          : (contactNumber ?? this.contactNumber),
    );
  }
}

// ── Update payloads ───────────────────────────────────────────────────────────

class UpdateOfficeLocationPayload {
  final int officeId;
  final int divisionId;
  final int districtId;
  final int? upazillaId;
  final int? unionId;

  const UpdateOfficeLocationPayload({
    required this.officeId,
    required this.divisionId,
    required this.districtId,
    this.upazillaId,
    this.unionId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'divisionId': divisionId,
      'districtId': districtId,
    };
    if (upazillaId != null) map['upazillaId'] = upazillaId;
    if (unionId != null) map['unionId'] = unionId;
    return map;
  }
}

class UpdateOfficeContactPayload {
  final int officeId;
  final String? contactNumber;

  const UpdateOfficeContactPayload({
    required this.officeId,
    this.contactNumber,
  });

  Map<String, dynamic> toMap() => {'contactNumber': contactNumber};
}
