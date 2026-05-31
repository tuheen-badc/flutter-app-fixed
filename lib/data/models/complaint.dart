// lib/data/models/complaint_models.dart

enum ComplaintStatus {
  NEW,
  IN_PROGRESS,
  CLOSED;

  String get displayName {
    switch (this) {
      case ComplaintStatus.NEW:
        return 'New';
      case ComplaintStatus.IN_PROGRESS:
        return 'In Progress';
      case ComplaintStatus.CLOSED:
        return 'Closed';
    }
  }
}

class ComplaintCriteria {
  final int page;
  final int size;
  final ComplaintStatus? status;
  final String? phone;
  final DateTime? fromDate;
  final DateTime? toDate;

  ComplaintCriteria({
    this.page = 0,
    this.size = 20,
    this.status,
    this.phone,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'size': size};

    if (status != null) map['status'] = status!.name;
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (fromDate != null) map['fromDate'] = fromDate!.toIso8601String();
    if (toDate != null) map['toDate'] = toDate!.toIso8601String();

    return map;
  }

  ComplaintCriteria copyWith({
    int? page,
    int? size,
    ComplaintStatus? status,
    String? phone,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearStatus = false,
    bool clearPhone = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return ComplaintCriteria(
      page: page ?? this.page,
      size: size ?? this.size,
      status: clearStatus ? null : (status ?? this.status),
      phone: clearPhone ? null : (phone ?? this.phone),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
    );
  }
}

class ComplaintUpdateModel {
  final ComplaintStatus status;
  final String finalRemarks;

  ComplaintUpdateModel({required this.status, required this.finalRemarks});

  Map<String, dynamic> toJson() {
    return {'status': status.name, 'finalRemarks': finalRemarks};
  }
}

class ComplaintItem {
  final int id;
  final ComplaintStatus status;
  final DateTime? statusChangedAt;
  final String? finalRemarks;
  final String? statusChangedBy;
  final String name;
  final String phone;
  final String role;
  final String message;

  ComplaintItem({
    required this.id,
    required this.status,
    this.statusChangedAt,
    this.finalRemarks,
    this.statusChangedBy,
    required this.name,
    required this.phone,
    required this.role,
    required this.message,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) {
    return ComplaintItem(
      id: json['id'],
      status: ComplaintStatus.values.byName(json['status']),
      statusChangedAt: json['statusChangedAt'] != null
          ? DateTime.parse(json['statusChangedAt'])
          : null,
      finalRemarks: json['finalRemarks'],
      statusChangedBy: json['statusChangedBy'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      message: json['message'],
    );
  }
}

class ComplaintResponse {
  final List<ComplaintItem> complaints;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ComplaintResponse({
    required this.complaints,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      complaints: (json['_embedded']['complaintModelList'] as List)
          .map((item) => ComplaintItem.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
      currentPage: json['page']['number'],
    );
  }
}
