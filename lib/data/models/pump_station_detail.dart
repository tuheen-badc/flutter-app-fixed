// data/models/pump_station_detail_view.dart

class PumpStationDetailView {
  final String name;
  final int divisionId;
  final String divisionName;
  final int districtId;
  final String districtName;
  final int? upazillaId;
  final String? upazillaName;
  final int? unionId;
  final String? unionName;
  final int officeId;
  final String officeName;
  final DateTime installationDate;

  // Present only for ADMIN / SUPER_ADMIN views
  final String? managerName;
  final String? managerPhone;
  final String? dataProviderPhone;

  const PumpStationDetailView({
    required this.name,
    required this.divisionId,
    required this.divisionName,
    required this.districtId,
    required this.districtName,
    this.upazillaId,
    this.upazillaName,
    this.unionId,
    this.unionName,
    required this.officeId,
    required this.officeName,
    required this.installationDate,
    this.managerName,
    this.managerPhone,
    this.dataProviderPhone,
  });

  factory PumpStationDetailView.fromJson(Map<String, dynamic> json) {
    return PumpStationDetailView(
      name: json['name'] as String,
      divisionId: json['divisionId'] as int,
      divisionName: json['divisionName'] as String,
      districtId: json['districtId'] as int,
      districtName: json['districtName'] as String,
      upazillaId: json['upazillaId'] as int?,
      upazillaName: json['upazillaName'] as String?,
      unionId: json['unionId'] as int?,
      unionName: json['unionName'] as String?,
      officeId: json['officeId'] as int,
      officeName: json['officeName'] as String,
      installationDate: DateTime.parse(json['installationDate'] as String),
      managerName: json['managerName'] as String?,
      managerPhone: json['managerPhone'] as String?,
      dataProviderPhone: json['dataProviderPhone'] as String?,
    );
  }

  /// True when the response included manager/staff details (ADMIN or SUPER_ADMIN view)
  bool get hasManagerInfo => managerName != null && managerPhone != null;

  /// True when the response included data provider phone (SUPER_ADMIN view only)
  bool get hasDataProviderInfo => dataProviderPhone != null;

  PumpStationDetailView copyWith({
    String? name,
    int? divisionId,
    String? divisionName,
    int? districtId,
    String? districtName,
    int? upazillaId,
    String? upazillaName,
    int? unionId,
    String? unionName,
    int? officeId,
    String? officeName,
    DateTime? installationDate,
    String? managerName,
    String? managerPhone,
    String? dataProviderPhone,
  }) {
    return PumpStationDetailView(
      name: name ?? this.name,
      divisionId: divisionId ?? this.divisionId,
      divisionName: divisionName ?? this.divisionName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      upazillaId: upazillaId ?? this.upazillaId,
      upazillaName: upazillaName ?? this.upazillaName,
      unionId: unionId ?? this.unionId,
      unionName: unionName ?? this.unionName,
      officeId: officeId ?? this.officeId,
      officeName: officeName ?? this.officeName,
      installationDate: installationDate ?? this.installationDate,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,
      dataProviderPhone: dataProviderPhone ?? this.dataProviderPhone,
    );
  }
}
