class PumpStationHistoryItem {
  final String userPhone;
  final String userName;

  final int pumpStationId;
  final String pumpStationName;

  final DateTime startedAt;
  final DateTime endedAt;
  final String endReason;

  final double volumeSupplied;
  final double balanceDeducted;

  PumpStationHistoryItem({
    required this.userPhone,
    required this.userName,
    required this.pumpStationId,
    required this.pumpStationName,
    required this.startedAt,
    required this.endedAt,
    required this.endReason,
    required this.volumeSupplied,
    required this.balanceDeducted,
  });

  factory PumpStationHistoryItem.fromJson(Map<String, dynamic> json) {
    return PumpStationHistoryItem(
      userPhone: json['userPhone'] as String,
      userName: json['userName'] as String,
      pumpStationId: json['pumpStationId'] as int,
      pumpStationName: json['pumpStationName'] as String,
      volumeSupplied: (json['volumeSupplied'] as num).toDouble(),
      balanceDeducted: (json['balanceDeducted'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: DateTime.parse(json['endedAt']),
      endReason: json['endReason'],
    );
  }

  Duration? get duration {
    if (endedAt == null) return null;
    return endedAt!.difference(startedAt);
  }

  String get durationFormatted {
    final dur = duration;
    if (dur == null) return 'Ongoing';

    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
