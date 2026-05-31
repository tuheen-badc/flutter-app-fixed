import 'package:demo_app/common/bloc/home/home_state.dart';
import 'package:demo_app/common/bloc/home/home_state_cubit.dart';
import 'package:demo_app/domain/entities/role_specific_data.dart';
import 'package:demo_app/presentation/auth/pages/login_screen.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/credit_recharge_screen.dart';
import 'package:demo_app/screens/pump_live_status_screen.dart';
import 'package:demo_app/screens/settings_screen.dart';
import 'package:demo_app/screens/transaction_history.dart';
import 'package:demo_app/screens/user_specific_analytics_screen.dart';
import 'package:demo_app/screens/user_tier_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/pump_station_history_screen.dart';
import '../../../screens/pump_station_list_screen.dart';
import '../../../screens/user_avatar.dart';
import '../../drawer/drawer_config.dart';
import 'credit_balance_card.dart';

class UserHomeScreen extends StatefulWidget {
  // No longer takes state as a prop — reads from cubit directly
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final PageController _tierPageController = PageController();

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
    _tierPageController.dispose();
    super.dispose();
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) {
      context.read<HomeCubit>().loadHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocBuilder here means every time HomeCubit emits a new state,
    // this widget rebuilds automatically with fresh data.
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF667eea)),
            ),
          );
        }

        if (state is HomeLoadedState) {
          final roleData = state.roleData as UserRolData;
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF8F9FA),
            drawer: RoleBasedDrawer(
              userData: state.userInfo,
              initialActiveItem: DrawerMenuItem.dashboard,
            ),
            body: Column(
              children: [
                _buildTopSection(state.userInfo),
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
                _buildBottomNav(state.userInfo),
              ],
            ),
          );
        }

        // Fallback for error or initial state
        return const Scaffold(
          backgroundColor: Color(0xFFF8F9FA),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF667eea)),
          ),
        );
      },
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
                          'User Dashboard',
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

  Widget _buildContent(UserRolData roleData) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreditBalanceCard(creditData: roleData.creditInfo),
          const SizedBox(height: 20),
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          _buildActionsGrid(roleData.userInfo),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(User userInfo) {
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
          'My Pumps',
          Icons.heat_pump,
          Colors.green,
          () =>
              _navigateAndRefresh(PumpStationControlScreen(userData: userInfo)),
        ),
        _buildQuickActionCard(
          'Transaction History',
          Icons.currency_exchange,
          Colors.orange,
          () =>
              _navigateAndRefresh(TransactionHistoryScreen(userData: userInfo)),
        ),
        _buildQuickActionCard(
          'Water Usages History',
          Icons.water_drop,
          Colors.purple,
          () =>
              _navigateAndRefresh(PumpStationHistoryScreen(userData: userInfo)),
        ),
        _buildQuickActionCard(
          'Tier Overview',
          Icons.loop,
          Colors.purple,
          () => _navigateAndRefresh(UserTierScreen(userData: userInfo)),
        ),
        _buildQuickActionCard(
          'Analytics',
          Icons.analytics,
          Colors.purple,
          () => _navigateAndRefresh(UserAnalyticsScreen(userData: userInfo)),
        ),
        _buildQuickActionCard(
          'Settings',
          Icons.settings_outlined,
          Colors.purple,
          () => _navigateAndRefresh(SettingsPage(user: userInfo)),
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
              _buildNavItem(
                Icons.dashboard_rounded,
                'Dashboard',
                true,
                userInfo,
              ),
              _buildNavItem(
                Icons.account_balance_wallet_rounded,
                'Recharge',
                false,
                userInfo,
              ),
              _buildNavItem(
                Icons.online_prediction,
                'Live Status',
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
        if (label == 'Live Status') {
          _navigateAndRefresh(PumpLiveStatusScreen(userData: user));
        } else if (label == 'Logout') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (label == 'Recharge') {
          _navigateAndRefresh(CreditRechargeScreen(userData: user));
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
