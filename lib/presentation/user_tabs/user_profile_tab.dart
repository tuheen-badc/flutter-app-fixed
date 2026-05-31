// presentation/user_tabs/upload_tab.dart
import 'package:demo_app/data/models/user_block_payload.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/user_block/user_block_state.dart';
import '../../common/bloc/user_block/user_block_state_cubit.dart';
import '../../common/bloc/user_profile/user_profile_by_id_state.dart';
import '../../common/bloc/user_profile/user_profile_by_id_state_cubit.dart';
import '../../domain/usecases/user_block.dart';
import '../../domain/usecases/user_info_by_id.dart';

class UserProfileTab extends StatefulWidget {
  final int userId;

  const UserProfileTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);

  BuildContext? _providerContext;

  void _loadUserProfile() {
    if (_providerContext == null) return;

    _providerContext!.read<UserProfileCubit>().loadUserProfile(
      useCase: serviceLocator<UserInfoByIdUseCase>(),
      userId: widget.userId,
    );
  }

  void _toggleBlockStatus(BuildContext context, User user) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: user.blocked ? _success : _danger,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                user.blocked ? 'Unblock User' : 'Block User',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            user.blocked
                ? 'Are you sure you want to unblock ${user.firstName} ${user.lastName}?'
                : 'Are you sure you want to block ${user.firstName} ${user.lastName}?',
            style: const TextStyle(fontSize: 14, color: _textSecondary),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final payload = UserBlockPayload(
                  userId: user.id,
                  blocked: !user.blocked,
                );
                context.read<UserBlockCubit>().toggleBlockStatus(
                  useCase: serviceLocator<UserBlockUseCase>(),
                  userId: user.id,
                  params: payload,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.blocked ? _success : _danger,
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
              child: Text(
                user.blocked ? 'Unblock' : 'Block',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserProfileCubit()
            ..loadUserProfile(
              useCase: serviceLocator<UserInfoByIdUseCase>(),
              userId: widget.userId,
            ),
        ),
        BlocProvider(create: (_) => UserBlockCubit()),
      ],
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return MultiBlocListener(
            listeners: [
              BlocListener<UserBlockCubit, UserBlockState>(
                listener: (context, state) {
                  if (state is UserBlockSuccessState) {
                    // Update the user profile state
                    final currentState = context.read<UserProfileCubit>().state;
                    if (currentState is UserProfileLoadedState) {
                      final updatedUser = User(
                        id: currentState.user.id,
                        firstName: currentState.user.firstName,
                        lastName: currentState.user.lastName,
                        phone: currentState.user.phone,
                        role: currentState.user.role,
                        blocked: state.blocked,
                        officeId: currentState.user.officeId,
                      );

                      context.read<UserProfileCubit>().emit(
                        currentState.copyWith(user: updatedUser),
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: _success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Reset state
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        context.read<UserBlockCubit>().resetState();
                      }
                    });
                  } else if (state is UserBlockFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: _danger,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );

                    context.read<UserBlockCubit>().resetState();
                  }
                },
              ),
            ],
            child: BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoadingState) {
                  return const _CenteredLoader();
                }

                if (state is UserProfileErrorState) {
                  return _ErrorView(
                    message: state.errorMessage,
                    onRetry: () => _loadUserProfile(),
                  );
                }

                if (state is UserProfileLoadedState) {
                  return _buildProfileContent(context, state.user);
                }

                return const _CenteredLoader();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration,
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_brand, _brand.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: user.blocked
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.blocked ? Icons.block : Icons.check_circle,
                        size: 16,
                        color: user.blocked ? _danger : _success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.blocked ? 'Blocked' : 'Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: user.blocked ? _danger : _success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // User ID
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'User ID',
                  value: '#${user.id}',
                ),
                const SizedBox(height: 16),

                // Phone
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: user.phone,
                ),
                const SizedBox(height: 16),

                // Role
                _InfoRow(
                  icon: Icons.work_outline,
                  label: 'Role',
                  value: user.role.name.toUpperCase(),
                  valueColor: _brand,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Block/Unblock Button
          _BlockButton(
            user: user,
            onPressed: () => _toggleBlockStatus(context, user),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _UserProfileTabState._border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _UserProfileTabState._textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: _UserProfileTabState._textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? _UserProfileTabState._textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlockButton extends StatelessWidget {
  final User user;
  final VoidCallback onPressed;

  const _BlockButton({required this.user, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBlockCubit, UserBlockState>(
      builder: (context, state) {
        final isLoading =
            state is UserBlockLoadingState && state.userId == user.id;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: user.blocked
                  ? _UserProfileTabState._success
                  : _UserProfileTabState._danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: _UserProfileTabState._textSecondary
                  .withOpacity(0.5),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        user.blocked ? Icons.check_circle : Icons.block,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user.blocked ? 'Unblock User' : 'Block User',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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
          color: _UserProfileTabState._brand,
          strokeWidth: 3,
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
              'Error Loading Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _UserProfileTabState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _UserProfileTabState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _UserProfileTabState._brand,
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
