import 'package:demo_app/data/models/user_tier_type.dart' show UserTier;

class PumpStationTierInfo {
  final int pumpStationId;
  final String pumpStationName;
  final UserTier userTier;
  final double? baseTierLimit;
  final double? tierTwoLimit;
  final double? tierUsed;

  PumpStationTierInfo({
    required this.pumpStationId,
    required this.pumpStationName,
    required this.userTier,
    this.baseTierLimit,
    this.tierTwoLimit,
    this.tierUsed,
  });

  factory PumpStationTierInfo.fromJson(Map<String, dynamic> json) {
    return PumpStationTierInfo(
      pumpStationId: json['pumpStationId'] as int,
      pumpStationName: json['pumpStationName'] as String,
      userTier: UserTier.fromString(json['userTier'] as String),
      baseTierLimit: json['baseTierLimit'] != null
          ? (json['baseTierLimit'] as num).toDouble()
          : null,
      tierTwoLimit: json['tierTwoLimit'] != null
          ? (json['tierTwoLimit'] as num).toDouble()
          : null,
      tierUsed: json['tierUsed'] != null
          ? (json['tierUsed'] as num).toDouble()
          : null,
    );
  }

  // Helper getters
  bool get isTierSet => userTier != UserTier.TIER_NOT_SET;

  double get remainingLimit {
    if (baseTierLimit == null || tierUsed == null) return 0.0;
    return baseTierLimit! - tierUsed!;
  }

  double get usagePercentage {
    if (baseTierLimit == null || tierUsed == null || baseTierLimit == 0) {
      return 0.0;
    }
    return (tierUsed! / baseTierLimit!) * 100;
  }
}
