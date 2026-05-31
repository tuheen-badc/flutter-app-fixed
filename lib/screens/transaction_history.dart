import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/transaction_history_common.dart';
import 'package:flutter/material.dart';

import '../presentation/drawer/drawer_config.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when user logs in
// ============================================================================
class TransactionHistoryScreen extends StatefulWidget {
  final User userData;

  const TransactionHistoryScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: RoleBasedDrawer(
        userData: widget.userData,
        initialActiveItem: DrawerMenuItem.transactionHistory,
      ),
      appBar: CustomTopBar(
        title: 'Transaction History',
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      body: TransactionHistoryContent(userId: widget.userData.id),
    );
  }
}
