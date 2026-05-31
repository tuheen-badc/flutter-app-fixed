class PumpUsersResponse {
  final List<PumpUserDto> userList;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PumpUsersResponse({
    required this.userList,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PumpUsersResponse.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>;
    final userListJson = embedded['pumpStationUserDtoList'] as List;
    final page = json['page'] as Map<String, dynamic>;

    return PumpUsersResponse(
      userList: userListJson.map((item) => PumpUserDto.fromJson(item)).toList(),
      totalElements: page['totalElements'] as int,
      totalPages: page['totalPages'] as int,
      currentPage: page['number'] as int,
    );
  }
}

class PumpUserDto {
  final int id;
  final String fullName;
  final String phone;
  final bool externalUser;
  final String? officeName;

  PumpUserDto({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.externalUser,
    this.officeName,
  });

  factory PumpUserDto.fromJson(Map<String, dynamic> json) {
    return PumpUserDto(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      externalUser: json['externalUser'],
      officeName: json['officeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'phone': phone};
  }
}
