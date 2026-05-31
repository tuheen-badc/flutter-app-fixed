// official_registration_container.dart
import 'package:demo_app/data/models/user_info.dart';
import 'package:flutter/material.dart';

import '../presentation/official_registration_tabs/new_registration_tab.dart';
import '../presentation/official_registration_tabs/registration_history_tab.dart';

class OfficialRegistrationScreen extends StatefulWidget {
  final int officeId;
  final UserRole role;

  const OfficialRegistrationScreen({
    Key? key,
    required this.officeId,
    required this.role,
  }) : super(key: key);

  @override
  State<OfficialRegistrationScreen> createState() =>
      _OfficialRegistrationScreenState();
}

class _OfficialRegistrationScreenState extends State<OfficialRegistrationScreen>
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

  // Method to switch to history tab
  void _switchToHistoryTab() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          RegistrationHistoryTab(
            officeId: widget.officeId,
            registrationRole: widget.role,
          ),
          NewRegistrationTab(
            onRegistrationSuccess: _switchToHistoryTab,
            officeId: widget.officeId,
            registrationRole: widget.role,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _brand,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.role == UserRole.ADMIN
            ? 'Pre-Registration(Admin)'
            : 'Pre-Registration(User)',
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
            isScrollable: true,
            tabAlignment: TabAlignment.center,
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
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(
                icon: Icon(Icons.history, size: 20),
                text: 'Registration History',
              ),
              Tab(
                icon: Icon(Icons.person_add, size: 20),
                text: 'New Registration',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
