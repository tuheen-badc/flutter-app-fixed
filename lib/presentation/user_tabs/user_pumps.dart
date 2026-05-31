import 'package:flutter/material.dart';

import '../../screens/pump_station_list_screen_common.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when user logs in
// ============================================================================
class UserPumpsTab extends StatelessWidget {
  final int userId;

  const UserPumpsTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PumpStationControlContent(
      userId: userId,
      userRole: 'ADMIN', // Admin viewing user's pumps - show as USER view
    );
  }
}
