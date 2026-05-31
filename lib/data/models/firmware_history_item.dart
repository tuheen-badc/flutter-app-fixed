// firmware_history_item.dart
class FirmwareHistoryItem {
  final String version;
  final DateTime uploadedAt;

  FirmwareHistoryItem({required this.version, required this.uploadedAt});

  factory FirmwareHistoryItem.fromJson(Map<String, dynamic> json) {
    return FirmwareHistoryItem(
      version: json['version'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

class FirmwareHistoryResponse {
  final List<FirmwareHistoryItem> items;

  FirmwareHistoryResponse({required this.items});

  factory FirmwareHistoryResponse.fromJson(List<dynamic> json) {
    return FirmwareHistoryResponse(
      items: json.map((item) => FirmwareHistoryItem.fromJson(item)).toList(),
    );
  }
}
