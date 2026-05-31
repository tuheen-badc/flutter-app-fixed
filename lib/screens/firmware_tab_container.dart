// firmware_tabs_screen.dart
import 'package:demo_app/data/models/user_info.dart';
import 'package:flutter/material.dart';

import '../presentation/firmware_tabs/history_tab.dart';
import '../presentation/firmware_tabs/upload_tab.dart';

class FirmwareTabsScreen extends StatefulWidget {
  final User userData;

  const FirmwareTabsScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<FirmwareTabsScreen> createState() => _FirmwareTabsScreenState();
}

class _FirmwareTabsScreenState extends State<FirmwareTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _brand = Color(0xFF3182CE);
  static const _textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [FirmwareUploadTab(), FirmwareHistoryTab()],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _brand,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Firmware Management',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: _surface,
          child: TabBar(
            controller: _tabController,
            labelColor: _brand,
            unselectedLabelColor: _textSecondary,
            indicatorColor: _brand,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.upload_file, size: 20), text: 'Upload'),
              Tab(icon: Icon(Icons.history, size: 20), text: 'History'),
            ],
          ),
        ),
      ),
    );
  }
}
