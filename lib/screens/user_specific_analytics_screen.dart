// user_analytics_screen.dart
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/user_analytics_common.dart';
import 'package:flutter/material.dart';

import '../presentation/drawer/drawer_config.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when accessed directly
// ============================================================================
class UserAnalyticsScreen extends StatefulWidget {
  final User userData;

  const UserAnalyticsScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<UserAnalyticsScreen> createState() => _UserAnalyticsScreenState();
}

class _UserAnalyticsScreenState extends State<UserAnalyticsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: RoleBasedDrawer(
        userData: widget.userData,
        initialActiveItem: DrawerMenuItem
            .analytics, // You'll need to add this to drawer config
      ),
      appBar: CustomTopBar(
        title: 'User Analytics',
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      body: UserAnalyticsContent(userId: widget.userData.id),
    );
  }
}
