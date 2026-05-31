// screens/office_user_list_screen.dart
import 'package:demo_app/data/models/office_user_list_criteria.dart';
import 'package:demo_app/data/models/office_user_list_response.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/screens/user_tab_container.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/office_user/office_user_state.dart';
import '../../common/bloc/office_user/office_user_state_cubit.dart';
import '../../domain/usecases/office_user_list.dart';

class OfficeUserListScreen extends StatefulWidget {
  final int officeId;
  final String officeName;
  final UserRole role;

  const OfficeUserListScreen({
    Key? key,
    required this.officeId,
    required this.officeName,
    required this.role,
  }) : super(key: key);

  @override
  State<OfficeUserListScreen> createState() => _OfficeUserListScreenState();
}

class _OfficeUserListScreenState extends State<OfficeUserListScreen> {
  int currentPage = 0;
  final int pageSize = 20;

  // Filter state
  bool? filterBlocked;
  String? filterPhone;
  final TextEditingController _phoneController = TextEditingController();

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

  BuildContext? _providerContext;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    if (_providerContext == null) return;
    _providerContext!.read<OfficeUserListCubit>().loadOfficeUsers(
      useCase: serviceLocator<OfficeUserListUseCase>(),
      params: OfficeUserListCriteria(
        officeId: widget.officeId,
        page: currentPage,
        size: pageSize,
        role: widget.role,
        blocked: filterBlocked,
        phone: filterPhone,
      ),
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;
    final providerContext = _providerContext!;
    bool? tempBlocked = filterBlocked;
    _phoneController.text = filterPhone ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter Users',
                style: TextStyle(
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
                      // Account Status
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
                            onTap: () =>
                                setDialogState(() => tempBlocked = null),
                          ),
                          _FilterChip(
                            label: 'Active',
                            selected: tempBlocked == false,
                            onTap: () =>
                                setDialogState(() => tempBlocked = false),
                          ),
                          _FilterChip(
                            label: 'Blocked',
                            selected: tempBlocked == true,
                            onTap: () =>
                                setDialogState(() => tempBlocked = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Phone filter
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
                        controller: _phoneController,
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
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      filterBlocked = null;
                      filterPhone = null;
                      _phoneController.clear();
                      currentPage = 0;
                    });
                    providerContext.read<OfficeUserListCubit>().loadOfficeUsers(
                      useCase: serviceLocator<OfficeUserListUseCase>(),
                      params: OfficeUserListCriteria(
                        officeId: widget.officeId,
                        page: 0,
                        size: pageSize,
                        role: widget.role,
                      ),
                    );
                  },
                ),
                _GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                _BrandButton(
                  label: 'Apply',
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      filterBlocked = tempBlocked;
                      filterPhone = _phoneController.text.isEmpty
                          ? null
                          : _phoneController.text;
                      currentPage = 0;
                    });
                    providerContext.read<OfficeUserListCubit>().loadOfficeUsers(
                      useCase: serviceLocator<OfficeUserListUseCase>(),
                      params: OfficeUserListCriteria(
                        officeId: widget.officeId,
                        page: 0,
                        size: pageSize,
                        blocked: filterBlocked,
                        phone: filterPhone,
                        role: widget.role,
                      ),
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
    final parts = <String>[];
    if (filterBlocked != null) parts.add(filterBlocked! ? 'Blocked' : 'Active');
    if (filterPhone != null && filterPhone!.isNotEmpty) {
      parts.add('Phone: $filterPhone');
    }
    return parts.isEmpty ? 'All Users' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfficeUserListCubit()
        ..loadOfficeUsers(
          useCase: serviceLocator<OfficeUserListUseCase>(),
          params: OfficeUserListCriteria(
            officeId: widget.officeId,
            page: currentPage,
            size: pageSize,
            role: widget.role,
          ),
        ),
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Office Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    widget.officeName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
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
                        onPressed: _showFilterDialog,
                        dense: true,
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: BlocBuilder<OfficeUserListCubit, OfficeUserListState>(
                    builder: (context, state) {
                      if (state is OfficeUserListLoadingState) {
                        return const _CenteredLoader();
                      }
                      if (state is OfficeUserListErrorState) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: _loadUsers,
                        );
                      }
                      if (state is OfficeUserListLoadedState) {
                        if (state.userList.isEmpty) {
                          return const _EmptyView();
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async => _loadUsers(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: state.userList.length,
                                  itemBuilder: (ctx, i) {
                                    final user = state.userList[i];
                                    return _AnimatedIn(
                                      delay: Duration(
                                        milliseconds: 40 * (i + 1),
                                      ),
                                      child: _buildUserCard(ctx, user),
                                    );
                                  },
                                ),
                              ),
                            ),
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

  Widget _buildUserCard(BuildContext context, OfficeUserItem user) {
    final isBlocked = user.blocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Stack(
        children: [
          // Main card content
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailsScreen(
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
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFEBF8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isBlocked
                            ? _danger.withOpacity(0.3)
                            : _brand.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: isBlocked ? _danger : _brand,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name — leave space for the badge on the right
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
                                fontSize: 13,
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
                              Expanded(
                                child: Text(
                                  user.officeName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow
                  const Icon(Icons.arrow_forward_ios, size: 16, color: _muted),
                ],
              ),
            ),
          ),

          // ── Active / Blocked badge — top right corner ──
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isBlocked ? _danger : _success,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Text(
                isBlocked ? 'Blocked' : 'Active',
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

// ── Reusable widgets ────────────────────────────────────────────────────────

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
            backgroundColor: const Color(0xFF3182CE),
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
            foregroundColor: const Color(0xFF718096),
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
          color: selected ? const Color(0xFF3182CE) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF3182CE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF2D3748),
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
          color: Color(0xFF3182CE),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No users match the current filters',
              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
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
        padding: const EdgeInsets.all(24),
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
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
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
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
              color: Color(0xFF2D3748),
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
