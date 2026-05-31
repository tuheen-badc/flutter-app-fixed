import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/pump_station_list_screen_common.dart';
import 'package:flutter/material.dart';

import '../presentation/drawer/drawer_config.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when user logs in
// ============================================================================
class PumpStationControlScreen extends StatefulWidget {
  final User userData;

  const PumpStationControlScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<PumpStationControlScreen> createState() =>
      _PumpStationControlScreenState();
}

class _PumpStationControlScreenState extends State<PumpStationControlScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: RoleBasedDrawer(
        userData: widget.userData,
        initialActiveItem: DrawerMenuItem.myPumps,
      ),
      appBar: CustomTopBar(
        title: 'Pump Station Control',
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      body: PumpStationControlContent(
        userId: widget.userData.id,
        userRole: widget.userData.role.name,
      ),
    );
  }
}
