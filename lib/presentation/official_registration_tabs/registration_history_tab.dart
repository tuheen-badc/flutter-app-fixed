// presentation/official_registration_tabs/registration_history_tab.dart
import 'package:demo_app/data/models/official_pre_registration.dart';
import 'package:demo_app/data/models/official_pre_registration_criteria.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/pre_registration/official_pre_registration.dart';
import '../../common/bloc/pre_registration/official_pre_registration_cubit.dart';
import '../../common/bloc/pre_registration/official_pre_registration_delete_state.dart';
import '../../common/bloc/pre_registration/official_pre_registration_delete_state_cubit.dart';
import '../../data/models/user_info.dart';
import '../../domain/usecases/pre_registration.dart';
import '../../domain/usecases/pre_registration_delete.dart';

class RegistrationHistoryTab extends StatefulWidget {
  final int officeId;
  final UserRole registrationRole;

  const RegistrationHistoryTab({
    Key? key,
    required this.officeId,
    required this.registrationRole,
  }) : super(key: key);

  @override
  State<RegistrationHistoryTab> createState() => _RegistrationHistoryTabState();
}

class _RegistrationHistoryTabState extends State<RegistrationHistoryTab> {
  int currentPage = 0;
  final int pageSize = 20;

  // Filter state
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

  void _loadRegistrations() {
    if (_providerContext == null) return;

    final criteria = OfficialPreRegistrationCriteria(
      page: currentPage,
      size: pageSize,
      phone: filterPhone,
      officeId: widget.officeId,
      preRegistrationRole: widget.registrationRole,
    );

    _providerContext!.read<OfficialPreRegistrationCubit>().loadRegistrations(
      useCase: serviceLocator<OfficialPreRegistrationUseCase>(),
      params: criteria,
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;

    final scaffoldContext = _providerContext!;
    phoneController.text = filterPhone ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Filter by Phone',
            style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary),
          ),
          content: TextField(
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
                borderSide: const BorderSide(color: _brand, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
                  filterPhone = null;
                  phoneController.clear();
                  currentPage = 0;
                });
                final criteria = OfficialPreRegistrationCriteria(
                  page: currentPage,
                  size: pageSize,
                  officeId: widget.officeId,
                  preRegistrationRole: widget.registrationRole,
                );
                scaffoldContext
                    .read<OfficialPreRegistrationCubit>()
                    .loadRegistrations(
                      useCase: serviceLocator<OfficialPreRegistrationUseCase>(),
                      params: criteria,
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
                  filterPhone = phoneController.text.isEmpty
                      ? null
                      : phoneController.text;
                  currentPage = 0;
                });
                final criteria = OfficialPreRegistrationCriteria(
                  page: currentPage,
                  size: pageSize,
                  phone: filterPhone,
                  officeId: widget.officeId,
                  preRegistrationRole: widget.registrationRole,
                );
                scaffoldContext
                    .read<OfficialPreRegistrationCubit>()
                    .loadRegistrations(
                      useCase: serviceLocator<OfficialPreRegistrationUseCase>(),
                      params: criteria,
                    );
              },
            ),
          ],
        );
      },
    );
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
    _loadRegistrations();
  }

  String _getFilterSummary() {
    if (filterPhone != null && filterPhone!.isNotEmpty) {
      return 'Phone: $filterPhone';
    }
    return 'All Registrations';
  }

  void _deleteRegistration(BuildContext context, int registrationId) {
    context.read<OfficialPreRegistrationDeleteCubit>().deleteRegistration(
      useCase: serviceLocator<OfficialPreRegistrationDeleteUseCase>(),
      registrationId: registrationId,
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    OfficialPreRegistrationItem registration,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: _danger, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Registration',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the pre-registration for ${registration.name}?',
            style: const TextStyle(fontSize: 14, color: _textSecondary),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            _GhostButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            _DangerButton(
              label: 'Delete',
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteRegistration(context, registration.id);
              },
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
          create: (_) => OfficialPreRegistrationCubit()
            ..loadRegistrations(
              useCase: serviceLocator<OfficialPreRegistrationUseCase>(),
              params: OfficialPreRegistrationCriteria(
                page: currentPage,
                size: pageSize,
                officeId: widget.officeId,
                preRegistrationRole: widget.registrationRole,
              ),
            ),
        ),
        BlocProvider(create: (_) => OfficialPreRegistrationDeleteCubit()),
      ],
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return MultiBlocListener(
            listeners: [
              BlocListener<
                OfficialPreRegistrationDeleteCubit,
                OfficialPreRegistrationDeleteState
              >(
                listener: (context, state) {
                  if (state is OfficialPreRegistrationDeleteSuccessState) {
                    // Remove the item from the list
                    final currentState = context
                        .read<OfficialPreRegistrationCubit>()
                        .state;
                    if (currentState is OfficialPreRegistrationLoadedState) {
                      final updatedList = currentState.registrationList
                          .where((item) => item.id != state.registrationId)
                          .toList();

                      context.read<OfficialPreRegistrationCubit>().emit(
                        currentState.copyWith(
                          registrationList: updatedList,
                          totalElements: currentState.totalElements - 1,
                        ),
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration deleted successfully!'),
                        backgroundColor: _success,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Reset state
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        context
                            .read<OfficialPreRegistrationDeleteCubit>()
                            .resetState();
                      }
                    });
                  } else if (state
                      is OfficialPreRegistrationDeleteFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: _danger,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );

                    context
                        .read<OfficialPreRegistrationDeleteCubit>()
                        .resetState();
                  }
                },
              ),
            ],
            child: Column(
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

                // Registrations List
                Expanded(
                  child:
                      BlocBuilder<
                        OfficialPreRegistrationCubit,
                        OfficialPreRegistrationState
                      >(
                        builder: (context, state) {
                          if (state is OfficialPreRegistrationLoadingState) {
                            return const _CenteredLoader();
                          }

                          if (state is OfficialPreRegistrationErrorState) {
                            return _ErrorView(
                              message: state.errorMessage,
                              onRetry: () => _loadRegistrations(),
                            );
                          }

                          if (state is OfficialPreRegistrationLoadedState) {
                            if (state.registrationList.isEmpty) {
                              return const _EmptyView();
                            }

                            return Column(
                              children: [
                                // List Items
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: state.registrationList.length,
                                    itemBuilder: (context, index) {
                                      final registration =
                                          state.registrationList[index];
                                      return _AnimatedIn(
                                        delay: Duration(
                                          milliseconds: 40 * (index + 1),
                                        ),
                                        child: _buildRegistrationCard(
                                          context,
                                          registration,
                                        ),
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
                                    onNext:
                                        state.currentPage < state.totalPages - 1
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

  Widget _buildRegistrationCard(
    BuildContext context,
    OfficialPreRegistrationItem registration,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: registration.pending
                        ? const Color(0xFFFFF4E6)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: registration.pending
                          ? _warning.withOpacity(0.3)
                          : _success.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    registration.pending
                        ? Icons.pending_outlined
                        : Icons.check_circle_outline,
                    color: registration.pending ? _warning : _success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registration.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 0.2,
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
                            registration.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: registration.pending
                        ? const Color(0xFFFFF4E6)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    registration.pending ? 'Pending' : 'Approved',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: registration.pending ? _warning : _success,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            const Divider(color: _border, height: 1),

            const SizedBox(height: 12),

            // Role Info
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: _textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Role: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  registration.registrationRole,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Delete Button (only for pending registrations)
            if (registration.pending) ...[
              const SizedBox(height: 16),
              _DeleteButton(
                registration: registration,
                onPressed: () => _showDeleteConfirmation(context, registration),
              ),
            ],
          ],
        ),
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

class _DeleteButton extends StatelessWidget {
  final OfficialPreRegistrationItem registration;
  final VoidCallback onPressed;

  const _DeleteButton({required this.registration, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      OfficialPreRegistrationDeleteCubit,
      OfficialPreRegistrationDeleteState
    >(
      builder: (context, state) {
        final isLoading =
            state is OfficialPreRegistrationDeleteLoadingState &&
            state.registrationId == registration.id;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _RegistrationHistoryTabState._danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              disabledBackgroundColor: _RegistrationHistoryTabState._muted,
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Delete Registration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
            backgroundColor: _RegistrationHistoryTabState._brand,
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

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DangerButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: _RegistrationHistoryTabState._danger,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            foregroundColor: _RegistrationHistoryTabState._textSecondary,
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

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: _RegistrationHistoryTabState._brand,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.app_registration, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Registrations Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _RegistrationHistoryTabState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pre-registrations match the current filter',
              style: TextStyle(
                fontSize: 14,
                color: _RegistrationHistoryTabState._textSecondary,
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
              'Error Loading Registrations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _RegistrationHistoryTabState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _RegistrationHistoryTabState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _RegistrationHistoryTabState._brand,
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
        color: _RegistrationHistoryTabState._surface,
        border: const Border(
          top: BorderSide(color: _RegistrationHistoryTabState._border),
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
              color: _RegistrationHistoryTabState._textPrimary,
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
