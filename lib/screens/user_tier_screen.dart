import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/user_tier_screen_common.dart';
import 'package:flutter/material.dart';

import '../presentation/drawer/drawer_config.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when user logs in
// ============================================================================
class UserTierScreen extends StatefulWidget {
  final User userData;
  final int? pumpStationId;

  const UserTierScreen({Key? key, required this.userData, this.pumpStationId})
    : super(key: key);

  @override
  State<UserTierScreen> createState() => _UserTierScreenState();
}

class _UserTierScreenState extends State<UserTierScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: RoleBasedDrawer(
        userData: widget.userData,
        initialActiveItem: DrawerMenuItem.tierUsages,
      ),
      appBar: CustomTopBar(
        title: 'My Tier Information',
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      body: UserTierContent(
        userId: widget.userData.id,
        pumpStationId: widget.pumpStationId,
      ),
    );
  }
}
