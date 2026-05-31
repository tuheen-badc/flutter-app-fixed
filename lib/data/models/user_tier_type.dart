enum UserTier {
  TIER_NOT_SET,
  TIER_1,
  TIER_2,
  TIER_3;

  // Convert from string to enum
  static UserTier fromString(String value) {
    switch (value) {
      case 'TIER_1':
        return UserTier.TIER_1;
      case 'TIER_2':
        return UserTier.TIER_2;
      case 'TIER_3':
        return UserTier.TIER_3;
      case 'TIER_NOT_SET':
      default:
        return UserTier.TIER_NOT_SET;
    }
  }

  // Convert enum to string
  String toServerString() {
    return name;
  }

  // Display name for UI
  String get displayName {
    switch (this) {
      case UserTier.TIER_1:
        return 'Tier 1';
      case UserTier.TIER_2:
        return 'Tier 2';
      case UserTier.TIER_3:
        return 'Tier 3';
      case UserTier.TIER_NOT_SET:
        return 'Not Set';
    }
  }
}
