// pump_station_history_screen_refactored.dart
import 'package:flutter/material.dart';

import '../../screens/pump_station_history_screen_common.dart';

class UserUsagesHistoryTab extends StatelessWidget {
  final int userId;

  const UserUsagesHistoryTab({Key? key, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PumpStationHistoryContent(
      userId: userId,
      userRole: 'USER', // Admin viewing user's history - show as USER view
    );
  }
}
