import 'package:demo_app/presentation/office_tabs/create_pump_station_screen.dart';
import 'package:demo_app/presentation/office_tabs/office_analytics_screen.dart';
import 'package:demo_app/presentation/office_tabs/office_detail_screen.dart';
import 'package:demo_app/presentation/office_tabs/office_pump_list_screen.dart';
import 'package:demo_app/presentation/office_tabs/office_user_list_screen.dart';
import 'package:demo_app/screens/water_usages_report_screen.dart';
import 'package:flutter/material.dart';

import '../data/models/user_info.dart';
import 'official_registration_tab_container.dart';

class OfficeOverviewScreen extends StatelessWidget {
  final int officeId;
  final String officeName;
  final User user;

  const OfficeOverviewScreen({
    Key? key,
    required this.officeId,
    required this.officeName,
    required this.user,
  }) : super(key: key);

  // Design tokens
  static const _brand = Color(0xFF3182CE);
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
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
            officeName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _brand.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Office ID: #$officeId',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions label
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 12),

          // Quick Actions Grid
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            children: [
              _buildQuickActionCard(
                'Office Details',
                Icons.info_outline,
                const Color(0xFF3182CE),
                () => _onOfficeDetails(context),
              ),
              _buildQuickActionCard(
                'Analytics',
                Icons.analytics_outlined,
                const Color(0xFF8B5CF6),
                () => _onOfficeAnalytics(context),
              ),
              _buildQuickActionCard(
                'Admin Pre-Registration',
                Icons.admin_panel_settings_outlined,
                const Color(0xFFF59E0B),
                () => _onAdminPreRegistration(context),
              ),
              _buildQuickActionCard(
                'User Pre-Registration',
                Icons.person_add_outlined,
                const Color(0xFF10B981),
                () => _onUserPreRegistration(context),
              ),
              _buildQuickActionCard(
                'Office Users',
                Icons.people_outline,
                const Color(0xFF06B6D4),
                () => _onOfficeUsers(context),
              ),
              _buildQuickActionCard(
                'Office Pumps',
                Icons.water_drop_outlined,
                const Color(0xFF3182CE),
                () => _onOfficePumps(context),
              ),
              _buildQuickActionCard(
                'Office Admins',
                Icons.manage_accounts_outlined,
                const Color(0xFFEF4444),
                () => _onOfficeAdmins(context),
              ),
              _buildQuickActionCard(
                'Create Pump',
                Icons.add_circle_outline,
                const Color(0xFF10B981),
                () => _onCreatePump(context),
              ),
              _buildQuickActionCard(
                'Report Download',
                Icons.download,
                const Color(0xFF10B981),
                () => _onReportDownload(context),
              ),
            ],
          ),
        ],
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

  // ── Navigation handlers ──────────────────────────────────────────────────

  void _onOfficeDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficeDetailScreen(
          officeId: officeId,
          officeName: officeName,
          userRole: user.role,
        ),
      ),
    );
  }

  void _onOfficeAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OfficeAnalyticsScreen(officeId: officeId, officeName: officeName),
      ),
    );
  }

  void _onAdminPreRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficialRegistrationScreen(
          officeId: officeId,
          role: UserRole.ADMIN,
        ),
      ),
    );
  }

  void _onUserPreRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OfficialRegistrationScreen(officeId: officeId, role: UserRole.USER),
      ),
    );
  }

  void _onOfficeUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficeUserListScreen(
          officeId: officeId,
          officeName: officeName,
          role: UserRole.USER,
        ),
      ),
    );
  }

  void _onOfficePumps(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficePumpsScreen(
          user: user,
          officeId: officeId,
          officeName: officeName,
        ),
      ),
    );
  }

  void _onOfficeAdmins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfficeUserListScreen(
          officeId: officeId,
          officeName: officeName,
          role: UserRole.ADMIN,
        ),
      ),
    );
  }

  void _onCreatePump(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePumpStationScreen(
          officeId: officeId,
          officeName: officeName,
          user: user,
        ),
      ),
    );
  }

  void _onReportDownload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WaterUsageReportScreen(officeId: officeId, userData: user),
      ),
    );
  }
}
