import 'package:demo_app/common/bloc/home/home_state.dart';
import 'package:demo_app/common/bloc/home/home_state_cubit.dart';
import 'package:demo_app/domain/entities/role_specific_data.dart';
import 'package:demo_app/presentation/auth/pages/login_screen.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/presentation/office_tabs/create_office_screen.dart';
import 'package:demo_app/screens/all_office_list_screen.dart';
import 'package:demo_app/screens/all_user_list_screen.dart';
import 'package:demo_app/screens/complaint_management_screen.dart';
import 'package:demo_app/screens/edit_water_pricing_screen.dart';
import 'package:demo_app/screens/electricity_status_screen.dart';
import 'package:demo_app/screens/firmware_tab_container.dart';
import 'package:demo_app/screens/office_selection_screen.dart';
import 'package:demo_app/screens/overall_analytics_screen.dart';
import 'package:demo_app/screens/pump_selection_screen.dart';
import 'package:demo_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/all_pump_station_history_screen.dart';
import '../../../screens/all_pump_station_list_screen.dart';
import '../../../screens/user_avatar.dart';
import '../../../screens/water_pricing_screen.dart';
import '../../drawer/drawer_config.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  final HomeLoadedState state;

  const SuperAdminHomeScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleData = widget.state.roleData as SuperAdminRoleData;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: RoleBasedDrawer(
        userData: widget.state.userInfo,
        initialActiveItem: DrawerMenuItem.dashboard,
      ),
      body: Column(
        children: [
          _buildTopSection(widget.state.userInfo),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeCubit>().loadHomeData();
              },
              child: SafeArea(
                top: false,
                child: _fadeAnimation != null && _slideAnimation != null
                    ? FadeTransition(
                        opacity: _fadeAnimation!,
                        child: SlideTransition(
                          position: _slideAnimation!,
                          child: _buildContent(roleData),
                        ),
                      )
                    : _buildContent(roleData),
              ),
            ),
          ),
          _buildBottomNav(widget.state.userInfo),
        ],
      ),
    );
  }

  Widget _buildTopSection(User userInfo) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const UserAvatar(radius: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Super Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${userInfo.firstName} ${userInfo.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SuperAdminRoleData roleData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildSuperAdminActionsGrid(roleData.userInfo),
        ],
      ),
    );
  }

  Widget _buildSuperAdminActionsGrid(User userInfo) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      padding: EdgeInsets.zero,
      children: [
        _buildQuickActionCard(
          'All Pumps',
          Icons.heat_pump,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AllPumpStationControlScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Usages History',
          Icons.history,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AllPumpStationHistoryScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'All Users',
          Icons.supervisor_account,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllUserListScreen(
                userData: userInfo,
                userType: UserRole.USER,
              ),
            ),
          ),
        ),
        _buildQuickActionCard(
          'All Admins',
          Icons.manage_accounts,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllUserListScreen(
                userData: userInfo,
                userType: UserRole.ADMIN,
              ),
            ),
          ),
        ),
        _buildQuickActionCard(
          'All Super Admins',
          Icons.switch_account_sharp,
          Colors.deepOrange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllUserListScreen(
                userData: userInfo,
                userType: UserRole.SUPER_ADMIN,
              ),
            ),
          ),
        ),
        _buildQuickActionCard(
          'View Water Pricing',
          Icons.currency_bitcoin,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaterPricingScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Edit Water Pricing',
          Icons.edit_document,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditWaterPricingScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Latest Electricity Status',
          Icons.electric_bolt,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ElectricityAvailabilityScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Pump Analytics',
          Icons.analytics,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OverallAnalyticsScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Feedback Management',
          Icons.report_problem_outlined,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ComplaintManagementScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Firmware',
          Icons.app_shortcut,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FirmwareTabsScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Offices',
          Icons.home_work_outlined,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllOfficeListScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Create Office',
          Icons.add_home_work_sharp,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOfficeScreen(userData: userInfo),
            ),
          ),
        ),
        _buildQuickActionCard(
          'Settings',
          Icons.settings,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(user: userInfo),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(User userInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', true, userInfo),
              _buildNavItem(Icons.water_damage, 'Manage Pump', false, userInfo),
              _buildNavItem(
                Icons.home_work_outlined,
                'Manage Office',
                false,
                userInfo,
              ),
              _buildNavItem(Icons.logout_rounded, 'Logout', false, userInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    User user,
  ) {
    return InkWell(
      onTap: () {
        if (label == 'Manage Office') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OfficeSelectionScreen(userData: user),
            ),
          );
        } else if (label == 'Manage Pump') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PumpSelectionScreen(userData: user),
            ),
          );
        } else if (label == 'Logout') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
