// all_user_list_screen.dart
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/data/models/user_list_criteria.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/user_tab_container.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/user_list/all_user_list_state.dart';
import '../common/bloc/user_list/all_user_list_state_cubit.dart';
import '../data/models/user_list_response.dart';
import '../domain/usecases/all_user_list.dart';
import '../presentation/drawer/drawer_config.dart';

class AllUserListScreen extends StatefulWidget {
  final User userData;
  final UserRole userType;

  const AllUserListScreen({
    Key? key,
    required this.userData,
    required this.userType,
  }) : super(key: key);

  @override
  State<AllUserListScreen> createState() => _AllUserListScreenState();
}

class _AllUserListScreenState extends State<AllUserListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPage = 0;
  final int pageSize = 20;

  // Filter state
  bool? filterBlocked;
  String? filterPhone;
  final TextEditingController phoneController = TextEditingController();

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);

  BuildContext? _providerContext;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // Get display title based on user type
  String get _screenTitle {
    switch (widget.userType) {
      case UserRole.ADMIN:
        return 'Admin Users';
      case UserRole.SUPER_ADMIN:
        return 'Super Admin Users';
      case UserRole.USER:
        return 'Regular Users';
      default:
        return 'Users';
    }
  }

  // Get user type label for filter summary
  String get _userTypeLabel {
    switch (widget.userType) {
      case UserRole.ADMIN:
        return 'Admins';
      case UserRole.SUPER_ADMIN:
        return 'Super Admins';
      case UserRole.USER:
        return 'Users';
      default:
        return 'Users';
    }
  }

  void _loadUsers() {
    if (_providerContext == null) return;

    final criteria = UserListCriteria(
      page: currentPage,
      size: pageSize,
      role: widget.userType,
      blocked: filterBlocked,
      phone: filterPhone,
    );

    _providerContext!.read<AllUserListCubit>().loadUsers(
      useCase: serviceLocator<AllUserListUseCase>(),
      params: criteria,
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;

    final scaffoldContext = _providerContext!;
    bool? tempBlocked = filterBlocked;
    phoneController.text = filterPhone ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Filter $_userTypeLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blocked Status Filter
                      const Text(
                        'Account Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: tempBlocked == null,
                            onTap: () {
                              setDialogState(() => tempBlocked = null);
                            },
                          ),
                          _FilterChip(
                            label: 'Active',
                            selected: tempBlocked == false,
                            onTap: () {
                              setDialogState(() => tempBlocked = false);
                            },
                          ),
                          _FilterChip(
                            label: 'Blocked',
                            selected: tempBlocked == true,
                            onTap: () {
                              setDialogState(() => tempBlocked = true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Phone Number Filter
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          prefixIcon: const Icon(Icons.phone, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _brand,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                _GhostButton(
                  label: 'Clear',
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      filterBlocked = null;
                      filterPhone = null;
                      phoneController.clear();
                      currentPage = 0;
                    });
                    final criteria = UserListCriteria(
                      page: currentPage,
                      size: pageSize,
                      role: widget.userType,
                    );
                    scaffoldContext.read<AllUserListCubit>().loadUsers(
                      useCase: serviceLocator<AllUserListUseCase>(),
                      params: criteria,
                    );
                  },
                ),
                _GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(builderContext).pop(),
                ),
                _BrandButton(
                  label: 'Apply',
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      filterBlocked = tempBlocked;
                      filterPhone = phoneController.text.isEmpty
                          ? null
                          : phoneController.text;
                      currentPage = 0;
                    });
                    final criteria = UserListCriteria(
                      page: currentPage,
                      size: pageSize,
                      role: widget.userType,
                      blocked: filterBlocked,
                      phone: filterPhone,
                    );
                    scaffoldContext.read<AllUserListCubit>().loadUsers(
                      useCase: serviceLocator<AllUserListUseCase>(),
                      params: criteria,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
    _loadUsers();
  }

  String _getFilterSummary() {
    List<String> parts = [];

    if (filterBlocked != null) {
      parts.add(filterBlocked! ? 'Blocked' : 'Active');
    }

    if (filterPhone != null && filterPhone!.isNotEmpty) {
      parts.add('Phone: $filterPhone');
    }

    return parts.isEmpty ? 'All $_userTypeLabel' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllUserListCubit()
        ..loadUsers(
          useCase: serviceLocator<AllUserListUseCase>(),
          params: UserListCriteria(
            page: currentPage,
            size: pageSize,
            role: widget.userType,
          ),
        ),
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: _bg,
            drawer: RoleBasedDrawer(
              userData: widget.userData,
              initialActiveItem: DrawerMenuItem.myPumps,
            ),
            appBar: CustomTopBar(
              title: _screenTitle,
              onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            body: Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: _cardDecoration,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: _textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getFilterSummary(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      _BrandButton(
                        label: 'Filter',
                        onPressed: () => _showFilterDialog(),
                        dense: true,
                      ),
                    ],
                  ),
                ),

                // Users List
                Expanded(
                  child: BlocBuilder<AllUserListCubit, AllUserListState>(
                    builder: (context, state) {
                      if (state is AllUserListLoadingState) {
                        return const _CenteredLoader();
                      }

                      if (state is AllUserListErrorState) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: () => _loadUsers(),
                        );
                      }

                      if (state is AllUserListLoadedState) {
                        if (state.userList.isEmpty) {
                          return _EmptyView(userTypeLabel: _userTypeLabel);
                        }

                        return Column(
                          children: [
                            // List Items
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: state.userList.length,
                                itemBuilder: (context, index) {
                                  final user = state.userList[index];
                                  return _AnimatedIn(
                                    delay: Duration(
                                      milliseconds: 40 * (index + 1),
                                    ),
                                    child: _buildUserCard(context, user),
                                  );
                                },
                              ),
                            ),

                            // Pagination Controls
                            if (state.totalPages > 1)
                              _PaginationBar(
                                current: state.currentPage + 1,
                                total: state.totalPages,
                                onPrev: state.currentPage > 0
                                    ? () => _goToPage(state.currentPage - 1)
                                    : null,
                                onNext: state.currentPage < state.totalPages - 1
                                    ? () => _goToPage(state.currentPage + 1)
                                    : null,
                              ),
                          ],
                        );
                      }

                      return const _CenteredLoader();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserItem user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Stack(
        // 👈 wrap with Stack
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(
                      userId: user.id,
                      userName: user.fullName,
                      role: UserRole.values.byName(user.role),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // User Avatar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: user.blocked
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEBF8FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: user.blocked
                              ? _danger.withOpacity(0.3)
                              : _brand.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: user.blocked ? _danger : _brand,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 👇 right padding to avoid overlap with badge
                          Padding(
                            padding: const EdgeInsets.only(right: 70),
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: _textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (user.officeName != null &&
                              user.officeName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.business,
                                  size: 14,
                                  color: _textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.officeName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // 👇 removed old inline status badge
                        ],
                      ),
                    ),

                    // Navigation Arrow
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _muted,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 👇 Active / Blocked badge — top right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: user.blocked ? _danger : _success,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Text(
                user.blocked ? 'Blocked' : 'Active',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration get _cardDecoration => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// --- Reusable Widgets ---

class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dense;

  const _BrandButton({required this.label, this.onPressed, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: _AllUserListScreenState._brand,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 16 : 20,
              vertical: dense ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => Colors.white.withOpacity(
                states.contains(WidgetState.pressed) ? 0.08 : 0.04,
              ),
            ),
          ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GhostButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style:
          TextButton.styleFrom(
            foregroundColor: _AllUserListScreenState._textSecondary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.black.withOpacity(0.04),
            ),
          ),
      child: Text(label),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _AllUserListScreenState._brand
              : _AllUserListScreenState._bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _AllUserListScreenState._brand
                : _AllUserListScreenState._border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : _AllUserListScreenState._textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: _AllUserListScreenState._brand,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String userTypeLabel;

  const _EmptyView({required this.userTypeLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $userTypeLabel Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AllUserListScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No users match the current filters',
              style: TextStyle(
                fontSize: 14,
                color: _AllUserListScreenState._textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AllUserListScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _AllUserListScreenState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _AllUserListScreenState._brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AllUserListScreenState._surface,
        border: const Border(
          top: BorderSide(color: _AllUserListScreenState._border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BrandButton(label: 'Previous', onPressed: onPrev),
          Text(
            'Page $current of $total',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _AllUserListScreenState._textPrimary,
            ),
          ),
          _BrandButton(label: 'Next', onPressed: onNext),
        ],
      ),
    );
  }
}

class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedIn({required this.child, this.delay = Duration.zero});

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .06),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
