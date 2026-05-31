// user_tabs_container.dart
import 'package:flutter/material.dart';

import '../data/models/user_info.dart';
import '../presentation/user_tabs/user_profile_tab.dart';
import '../presentation/user_tabs/user_pumps.dart';
import '../presentation/user_tabs/user_specific_analytics.dart';
import '../presentation/user_tabs/user_tier_info.dart';
import '../presentation/user_tabs/user_transaction.dart';
import '../presentation/user_tabs/user_water_usages_history.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final UserRole role;

  const UserDetailsScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.role,
  }) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _brand = Color(0xFF3182CE);
  static const _textSecondary = Color(0xFF718096);

  // Determine if user is admin or super admin
  bool get _isAdminOrSuperAdmin =>
      widget.role == UserRole.ADMIN || widget.role == UserRole.SUPER_ADMIN;

  // Get the number of tabs based on role
  int get _tabCount => _isAdminOrSuperAdmin ? 1 : 6;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
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
      body: TabBarView(controller: _tabController, children: _buildTabViews()),
    );
  }

  // Build tab views based on role
  List<Widget> _buildTabViews() {
    if (_isAdminOrSuperAdmin) {
      // Only show profile tab for admin/super admin
      return [UserProfileTab(userId: widget.userId)];
    } else {
      // Show all tabs for regular users
      return [
        UserProfileTab(userId: widget.userId),
        UserTransactionsTab(userId: widget.userId),
        UserUsagesHistoryTab(userId: widget.userId),
        UserTierTab(userId: widget.userId),
        UserPumpsTab(userId: widget.userId),
        UserAnalyticsTab(userId: widget.userId),
      ];
    }
  }

  // Build tabs based on role
  List<Widget> _buildTabs() {
    if (_isAdminOrSuperAdmin) {
      // Only profile tab for admin/super admin
      return const [Tab(icon: Icon(Icons.person, size: 20), text: 'Profile')];
    } else {
      // All tabs for regular users
      return const [
        Tab(icon: Icon(Icons.person, size: 20), text: 'Profile'),
        Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Transactions'),
        Tab(icon: Icon(Icons.history, size: 20), text: 'Usages History'),
        Tab(icon: Icon(Icons.military_tech, size: 20), text: 'Tier Info'),
        Tab(icon: Icon(Icons.water_drop, size: 20), text: 'User Pumps'),
        Tab(icon: Icon(Icons.analytics, size: 20), text: 'Analytics'),
      ];
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _brand,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            widget.role.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
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
            tabs: _buildTabs(),
          ),
        ),
      ),
    );
  }
}
