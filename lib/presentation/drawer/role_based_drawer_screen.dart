// lib/screens/role_based_drawer_screen.dart

import 'package:flutter/material.dart';

import '../../data/models/user_info.dart';
import '../../screens/user_avatar.dart';
import '../auth/pages/login_screen.dart';
import 'drawer_config.dart';

class RoleBasedDrawer extends StatefulWidget {
  final User userData;
  final DrawerMenuItem? initialActiveItem; // Made nullable

  const RoleBasedDrawer({
    Key? key,
    required this.userData,
    this.initialActiveItem, // Optional now
  }) : super(key: key);

  @override
  State<RoleBasedDrawer> createState() => _RoleBasedDrawerState();
}

class _RoleBasedDrawerState extends State<RoleBasedDrawer> {
  DrawerMenuItem? _activeItem; // Made nullable
  late List<DrawerItemConfig> _menuItems;

  @override
  void initState() {
    super.initState();
    _activeItem = widget.initialActiveItem;
    _menuItems = RoleBasedDrawerConfig.getMenuItems(widget.userData.role);
  }

  void _onItemSelected(DrawerItemConfig config) {
    if (_activeItem == config.item) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _activeItem = config.item;
    });

    Navigator.pop(context);
    _navigateToScreen(config);
  }

  void _navigateToScreen(DrawerItemConfig config) {
    // Special handling for Settings - use simple push to show back button
    if (config.item == DrawerMenuItem.settings) {
      final screen = config.screenBuilder(widget.userData);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      return;
    }

    // For all other screens - replace the entire stack
    final screen = config.screenBuilder(widget.userData);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => route.isFirst,
    );
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const Divider(color: Colors.white24, height: 1),
            ..._buildMenuItems(),
            const Divider(color: Colors.white24, height: 1),
            _buildLogoutItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const UserAvatar(radius: 30),
          const SizedBox(height: 12),
          Text(
            '${widget.userData.firstName} ${widget.userData.lastName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.userData.phone,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              RoleBasedDrawerConfig.getRoleDisplayName(widget.userData.role),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    return _menuItems.map((config) {
      return _buildDrawerItem(config);
    }).toList();
  }

  Widget _buildDrawerItem(DrawerItemConfig config) {
    final bool isActive = _activeItem != null && _activeItem == config.item;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          config.icon,
          color: isActive ? const Color(0xFFFFD700) : Colors.white,
          size: 22,
        ),
        title: Text(
          config.title,
          style: TextStyle(
            color: isActive ? const Color(0xFFFFD700) : Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () => _onItemSelected(config),
        hoverColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.white, size: 22),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: _handleLogout,
        hoverColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
