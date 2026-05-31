// user_analytics_tab.dart
import 'package:flutter/material.dart';

import '../../screens/user_analytics_common.dart';

class UserAnalyticsTab extends StatelessWidget {
  final int userId;

  const UserAnalyticsTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAnalyticsContent(userId: userId);
  }
}
