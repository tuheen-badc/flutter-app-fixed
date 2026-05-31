// tabs/pump_users.dart
import 'package:demo_app/data/models/user_of_pump_station.dart';
import 'package:demo_app/domain/usecases/users_of_pump.dart';
import 'package:demo_app/presentation/pump_tabs/tab_design_tokens.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/users_of_pump/users_of_pump_state.dart';
import '../../common/bloc/users_of_pump/users_of_pump_state_cubit.dart';
import '../../data/models/user_info.dart';
import '../../data/models/user_of_pump_station_response.dart';
import '../../screens/user_tab_container.dart';

class UsersTab extends StatefulWidget {
  final int pumpStationId;

  const UsersTab({Key? key, required this.pumpStationId}) : super(key: key);

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final TextEditingController _phoneController = TextEditingController();

  int currentPage = 0;
  final int pageSize = 20;
  int? totalElements;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUsers(BuildContext ctx) {
    ctx.read<PumpUsersCubit>().loadPumpUsers(
      useCase: serviceLocator<UsersOfPumpUseCase>(),
      params: UserOfPumpStationParam(
        pumpStationId: widget.pumpStationId,
        page: currentPage,
        size: pageSize,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      ),
    );
  }

  void _goToPage(int page, BuildContext ctx) {
    setState(() => currentPage = page);
    _loadUsers(ctx);
  }

  void _showFilterDialog(BuildContext providerContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String tempPhone = _phoneController.text;

        return AlertDialog(
          backgroundColor: DesignTokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Filter Users',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: DesignTokens.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: tempPhone),
                onChanged: (value) => tempPhone = value,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: const Icon(Icons.phone, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _phoneController.clear();
                  currentPage = 0;
                });
                _loadUsers(providerContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: DesignTokens.textSecondary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: DesignTokens.textSecondary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _phoneController.text = tempPhone;
                  currentPage = 0;
                });
                _loadUsers(providerContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getFilterSummary() {
    if (_phoneController.text.isNotEmpty) {
      return 'Phone: ${_phoneController.text}';
    }
    return totalElements != null ? 'All Users: $totalElements' : 'All Users';
  }

  void _navigateToUserDetail(BuildContext context, PumpUserDto user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          userId: user.id,
          userName: user.fullName,
          role: UserRole.USER,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PumpUsersCubit()
        ..loadPumpUsers(
          useCase: serviceLocator<UsersOfPumpUseCase>(),
          params: UserOfPumpStationParam(
            pumpStationId: widget.pumpStationId,
            page: currentPage,
            size: pageSize,
          ),
        ),
      child: Builder(
        builder: (providerContext) {
          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: DesignTokens.cardDecoration,
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: DesignTokens.textSecondary,
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
                          color: DesignTokens.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showFilterDialog(providerContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User List
              Expanded(
                child: BlocBuilder<PumpUsersCubit, PumpUsersState>(
                  builder: (context, state) {
                    if (state is PumpUsersLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: DesignTokens.brand,
                          strokeWidth: 3,
                        ),
                      );
                    }

                    if (state is PumpUsersErrorState) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error Loading Users',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: DesignTokens.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => _loadUsers(providerContext),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignTokens.brand,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is PumpUsersLoadedState) {
                      // Update total elements for filter summary
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && totalElements != state.totalElements) {
                          setState(() {
                            totalElements = state.totalElements;
                          });
                        }
                      });

                      if (state.userList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Users Found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _phoneController.text.isNotEmpty
                                    ? 'No users found with the specified phone number'
                                    : 'No users are registered for this pump station',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // User List
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                _loadUsers(providerContext);
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
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
                          ),

                          // Pagination Controls
                          if (state.totalPages > 1)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: DesignTokens.surface,
                                border: const Border(
                                  top: BorderSide(color: DesignTokens.border),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: state.currentPage > 0
                                        ? () => _goToPage(
                                            state.currentPage - 1,
                                            providerContext,
                                          )
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DesignTokens.brand,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Previous',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Page ${state.currentPage + 1} of ${state.totalPages}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        state.currentPage < state.totalPages - 1
                                        ? () => _goToPage(
                                            state.currentPage + 1,
                                            providerContext,
                                          )
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DesignTokens.brand,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Next',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, PumpUserDto user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: DesignTokens.cardDecoration,
      child: Stack(
        // 👈 wrap with Stack
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: user.externalUser
                ? null
                : () => _navigateToUserDetail(context, user),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.brand.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: DesignTokens.brand,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: DesignTokens.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: DesignTokens.textSecondary,
                                fontWeight: FontWeight.w600,
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
                                color: DesignTokens.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.officeName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: DesignTokens.textSecondary,
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

                  // Arrow Icon
                  if (!user.externalUser)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DesignTokens.brand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: DesignTokens.brand,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (user.externalUser)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B), // warning amber
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'External',
                  style: TextStyle(
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
