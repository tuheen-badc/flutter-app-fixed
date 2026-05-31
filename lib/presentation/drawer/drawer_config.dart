// lib/config/navigation/drawer_config.dart

import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_info.dart';
import '../../screens/all_pump_station_history_screen.dart';
import '../../screens/all_pump_station_list_screen.dart';
import '../../screens/complaint_submission_screen.dart';
import '../../screens/electricity_status_screen.dart';
import '../../screens/pump_selection_screen.dart';
import '../../screens/pump_station_history_screen.dart';
import '../../screens/pump_station_list_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/transaction_history.dart';
import '../../screens/user_tier_screen.dart';
import '../../screens/water_pricing_screen.dart';
import '../home/pages/home_screen.dart';

enum DrawerMenuItem {
  dashboard,
  logout,
  settings,
  helpSupport,
  allPumps,
  allPumpHistory,
  pumpSelection,
  electricityStatus,
  ratePerTier,
  myPumps,
  myPumpHistory,
  transactionHistory,
  tierUsages,
  userManagement,
  systemSettings,
  analytics, pumpUsagesHistory, rechargeHistory,
}

class DrawerItemConfig {
  final DrawerMenuItem item;
  final IconData icon;
  final String title;
  final Widget Function(User) screenBuilder;

  const DrawerItemConfig({
    required this.item,
    required this.icon,
    required this.title,
    required this.screenBuilder,
  });
}

class RoleBasedDrawerConfig {
  static List<DrawerItemConfig> getMenuItems(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return _superAdminItems;
      case UserRole.ADMIN:
        return _adminItems;
      case UserRole.USER:
        return _userItems;
    }
  }

  // SuperAdmin Menu Items
  static final List<DrawerItemConfig> _superAdminItems = [
    DrawerItemConfig(
      item: DrawerMenuItem.dashboard,
      icon: Icons.dashboard,
      title: 'Dashboard',
      screenBuilder: (user) => HomeScreen(),
    ),
    // DrawerItemConfig(
    //   item: DrawerMenuItem.userManagement,
    //   icon: Icons.people,
    //   title: 'User Management',
    //   screenBuilder: (user) => UserManagementScreen(userData: user),
    // ),
    DrawerItemConfig(
      item: DrawerMenuItem.allPumps,
      icon: Icons.water_drop,
      title: 'All Pump Stations',
      screenBuilder: (user) => AllPumpStationControlScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.allPumpHistory,
      icon: Icons.history,
      title: 'All Pump History',
      screenBuilder: (user) => AllPumpStationHistoryScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.pumpSelection,
      icon: Icons.select_all,
      title: 'Pump Selection',
      screenBuilder: (user) => PumpSelectionScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.electricityStatus,
      icon: Icons.electrical_services,
      title: 'Electricity Status',
      screenBuilder: (user) => ElectricityAvailabilityScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.ratePerTier,
      icon: Icons.attach_money,
      title: 'Water Rates',
      screenBuilder: (user) => WaterPricingScreen(userData: user),
    ),
    // DrawerItemConfig(
    //   item: DrawerMenuItem.systemSettings,
    //   icon: Icons.admin_panel_settings,
    //   title: 'System Settings',
    //   screenBuilder: (user) => SystemSettingsScreen(userData: user),
    // ),
    // DrawerItemConfig(
    //   item: DrawerMenuItem.analytics,
    //   icon: Icons.analytics,
    //   title: 'Analytics',
    //   screenBuilder: (user) => AnalyticsScreen(userData: user),
    // ),
    DrawerItemConfig(
      item: DrawerMenuItem.settings,
      icon: Icons.settings,
      title: 'Settings',
      screenBuilder: (user) => SettingsPage(user: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.helpSupport,
      icon: Icons.help,
      title: 'Help & Support',
      screenBuilder: (user) => ComplaintSubmissionScreen(userData: user),
    ),
  ];

  // Admin Menu Items
  static final List<DrawerItemConfig> _adminItems = [
    DrawerItemConfig(
      item: DrawerMenuItem.dashboard,
      icon: Icons.dashboard,
      title: 'Dashboard',
      screenBuilder: (user) => HomeScreen(),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.allPumps,
      icon: Icons.water_drop,
      title: 'All Pump Stations',
      screenBuilder: (user) => AllPumpStationControlScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.allPumpHistory,
      icon: Icons.history,
      title: 'Water Usage History',
      screenBuilder: (user) => AllPumpStationHistoryScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.pumpSelection,
      icon: Icons.select_all,
      title: 'Pump Selection',
      screenBuilder: (user) => PumpSelectionScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.electricityStatus,
      icon: Icons.electrical_services,
      title: 'Electricity Status',
      screenBuilder: (user) => ElectricityAvailabilityScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.ratePerTier,
      icon: Icons.attach_money,
      title: 'Water Rates',
      screenBuilder: (user) => WaterPricingScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.settings,
      icon: Icons.settings,
      title: 'Settings',
      screenBuilder: (user) => SettingsPage(user: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.helpSupport,
      icon: Icons.help,
      title: 'Help & Support',
      screenBuilder: (user) => ComplaintSubmissionScreen(userData: user),
    ),
  ];

  // User Menu Items
  static final List<DrawerItemConfig> _userItems = [
    DrawerItemConfig(
      item: DrawerMenuItem.dashboard,
      icon: Icons.dashboard,
      title: 'Dashboard',
      screenBuilder: (user) => HomeScreen(),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.myPumps,
      icon: Icons.water,
      title: 'My Pumps',
      screenBuilder: (user) => PumpStationControlScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.transactionHistory,
      icon: Icons.receipt_long,
      title: 'Transaction History',
      screenBuilder: (user) => TransactionHistoryScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.tierUsages,
      icon: Icons.bar_chart,
      title: 'Tier Usage',
      screenBuilder: (user) => UserTierScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.myPumpHistory,
      icon: Icons.history,
      title: 'Water Usage History',
      screenBuilder: (user) => PumpStationHistoryScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.ratePerTier,
      icon: Icons.attach_money,
      title: 'Water Rates',
      screenBuilder: (user) => WaterPricingScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.electricityStatus,
      icon: Icons.electrical_services,
      title: 'Electricity Status',
      screenBuilder: (user) => ElectricityAvailabilityScreen(userData: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.settings,
      icon: Icons.settings,
      title: 'Settings',
      screenBuilder: (user) => SettingsPage(user: user),
    ),
    DrawerItemConfig(
      item: DrawerMenuItem.helpSupport,
      icon: Icons.help,
      title: 'Help & Support',
      screenBuilder: (user) => ComplaintSubmissionScreen(userData: user),
    ),
  ];

  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.ADMIN:
        return 'Admin';
      case UserRole.USER:
        return 'User';
    }
  }
}
