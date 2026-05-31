// pump_live_status_model.dart
import 'package:demo_app/data/models/user_tier_type.dart';

class PumpLiveStatusResponse {
  final double? availableCredit;
  final PumpUserTier? userTier;
  final WaterPricing? waterPricing;
  final DateTime? startTime;
  final bool running;

  PumpLiveStatusResponse({
    this.availableCredit,
    this.userTier,
    this.waterPricing,
    this.startTime,
    required this.running,
  });

  factory PumpLiveStatusResponse.fromJson(Map<String, dynamic> json) {
    return PumpLiveStatusResponse(
      availableCredit: (json['availableCredit'] as num?)?.toDouble(),
      userTier: json['userTier'] != null
          ? PumpUserTier.fromJson(json['userTier'])
          : null,
      waterPricing: json['waterPricing'] != null
          ? WaterPricing.fromJson(json['waterPricing'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      running: json['running'] ?? false,
    );
  }
}

class PumpUserTier {
  final int pumpStationId;
  final String pumpStationName;
  final UserTier userTier;
  final double? baseTierLimit;
  final double? tierTwoLimit;
  final double? tierUsed;

  /// Tier is actionable only when explicitly set AND baseTierLimit is defined.
  bool get isTierSet =>
      userTier != UserTier.TIER_NOT_SET && baseTierLimit != null;

  PumpUserTier({
    required this.pumpStationId,
    required this.pumpStationName,
    required this.userTier,
    this.baseTierLimit,
    this.tierTwoLimit,
    this.tierUsed,
  });

  factory PumpUserTier.fromJson(Map<String, dynamic> json) {
    return PumpUserTier(
      pumpStationId: json['pumpStationId'],
      pumpStationName: json['pumpStationName'],
      userTier: UserTier.fromString(json['userTier'] ?? 'TIER_NOT_SET'),
      baseTierLimit: (json['baseTierLimit'] as num?)?.toDouble(),
      tierTwoLimit: (json['tierTwoLimit'] as num?)?.toDouble(),
      tierUsed: (json['tierUsed'] as num?)?.toDouble(),
    );
  }
}

class WaterPricing {
  final double tierOneRate;
  final double tierTwoRate;
  final double tierThreeRate;

  WaterPricing({
    required this.tierOneRate,
    required this.tierTwoRate,
    required this.tierThreeRate,
  });

  factory WaterPricing.fromJson(Map<String, dynamic> json) {
    return WaterPricing(
      tierOneRate: (json['tierOneRate'] as num).toDouble(),
      tierTwoRate: (json['tierTwoRate'] as num).toDouble(),
      tierThreeRate: (json['tierThreeRate'] as num).toDouble(),
    );
  }
}
