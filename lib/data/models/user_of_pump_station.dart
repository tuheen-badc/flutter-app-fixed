class UserOfPumpStationParam {
  final int page;
  final int size;
  final int pumpStationId;
  final String? phone;

  UserOfPumpStationParam({
    required this.page,
    required this.size,
    required this.pumpStationId,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'page': page, 'size': size};

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    return json;
  }
}
