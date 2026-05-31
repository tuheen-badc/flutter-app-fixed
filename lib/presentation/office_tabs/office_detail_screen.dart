// screens/office_detail_screen.dart
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/office_details/edit_office_detail_state.dart';
import '../../common/bloc/office_details/edit_office_detail_state_cubit.dart';
import '../../common/bloc/office_details/office_detail_state.dart';
import '../../common/bloc/office_details/office_detail_state_cubit.dart';
import '../../data/models/office_detail_model.dart';
import '../../domain/usecases/office_detail.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _T {
  static const surface = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const muted = Color(0xFFA0AEC0);
  static const border = Color(0xFFE2E8F0);
  static const brand = Color(0xFF3182CE);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static BoxDecoration get card => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: border),
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

// =============================================================================
// Entry-point screen
// =============================================================================

class OfficeDetailScreen extends StatelessWidget {
  final int officeId;
  final String officeName;
  final UserRole userRole;

  const OfficeDetailScreen({
    Key? key,
    required this.officeId,
    required this.officeName,
    required this.userRole,
  }) : super(key: key);

  bool get _canEdit =>
      userRole == UserRole.ADMIN || userRole == UserRole.SUPER_ADMIN;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OfficeDetailViewCubit()
            ..loadDetail(
              useCase: serviceLocator<GetOfficeDetailUseCase>(),
              officeId: officeId,
            ),
        ),
        BlocProvider(create: (_) => OfficeDetailEditCubit()),
      ],
      child: Builder(
        builder: (ctx) =>
            BlocListener<OfficeDetailEditCubit, OfficeDetailEditState>(
              listener: (context, editState) {
                if (editState is OfficeDetailEditSuccessState) {
                  // Patch view cubit with fresh data — no reload needed
                  final viewCubit = context.read<OfficeDetailViewCubit>();
                  final current = viewCubit.state;
                  if (current is OfficeDetailViewLoadedState) {
                    viewCubit.emit(
                      current.copyWith(detail: editState.updatedDetail),
                    );
                  }
                  context.read<OfficeDetailEditCubit>().resetState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Updated successfully'),
                      backgroundColor: _T.success,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (editState is OfficeDetailEditErrorState) {
                  context.read<OfficeDetailEditCubit>().resetState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editState.errorMessage),
                      backgroundColor: _T.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Scaffold(
                backgroundColor: _T.bg,
                appBar: AppBar(
                  backgroundColor: _T.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Office Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        officeName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    BlocBuilder<OfficeDetailViewCubit, OfficeDetailViewState>(
                      builder: (context, state) => IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: () =>
                            context.read<OfficeDetailViewCubit>().refresh(
                              useCase: serviceLocator<GetOfficeDetailUseCase>(),
                              officeId: officeId,
                            ),
                      ),
                    ),
                  ],
                ),
                body: BlocBuilder<OfficeDetailViewCubit, OfficeDetailViewState>(
                  builder: (context, state) {
                    if (state is OfficeDetailViewLoadingState) {
                      return const _CenteredLoader();
                    }

                    if (state is OfficeDetailViewErrorState) {
                      return _ErrorView(
                        message: state.errorMessage,
                        onRetry: () =>
                            context.read<OfficeDetailViewCubit>().loadDetail(
                              useCase: serviceLocator<GetOfficeDetailUseCase>(),
                              officeId: officeId,
                            ),
                      );
                    }

                    if (state is OfficeDetailViewLoadedState) {
                      return _DetailBody(
                        detail: state.detail,
                        canEdit: _canEdit,
                        onRefresh: () =>
                            context.read<OfficeDetailViewCubit>().refresh(
                              useCase: serviceLocator<GetOfficeDetailUseCase>(),
                              officeId: officeId,
                            ),
                      );
                    }

                    return const _CenteredLoader();
                  },
                ),
              ),
            ),
      ),
    );
  }
}

// =============================================================================
// Detail body
// =============================================================================

class _DetailBody extends StatelessWidget {
  final OfficeDetail detail;
  final bool canEdit;
  final VoidCallback onRefresh;

  const _DetailBody({
    required this.detail,
    required this.canEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: _T.brand,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ── Name header ───────────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 30),
            child: _NameHeader(detail: detail),
          ),
          const SizedBox(height: 16),

          // ── Location card ─────────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 70),
            child: _LocationCard(detail: detail, canEdit: canEdit),
          ),
          const SizedBox(height: 16),

          // ── Contact card ──────────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 110),
            child: _ContactCard(detail: detail, canEdit: canEdit),
          ),
          const SizedBox(height: 16),

          // ── Created At card ───────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 150),
            child: _CreatedAtCard(createdAt: detail.createdAt),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Name header
// =============================================================================

class _NameHeader extends StatelessWidget {
  final OfficeDetail detail;

  const _NameHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _T.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _T.brand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: _T.brand, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OFFICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _T.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID #${detail.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _T.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Location card
// =============================================================================

class _LocationCard extends StatelessWidget {
  final OfficeDetail detail;
  final bool canEdit;

  const _LocationCard({required this.detail, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Location',
            trailing: canEdit
                ? _EditIconButton(onPressed: () => _showEditDialog(context))
                : null,
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.location_city,
                        label: 'Division',
                        value: detail.divisionName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.map_outlined,
                        label: 'District',
                        value: detail.districtName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.place_outlined,
                        label: 'Upazilla',
                        value: detail.upazillaName ?? '—',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.location_on_outlined,
                        label: 'Union',
                        value: detail.unionName ?? '—',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final initialSelection = LocationSelection(
      division: Division(
        id: detail.divisionId,
        name: detail.divisionName,
        bnName: '',
      ),
      district: District(
        id: detail.districtId,
        name: detail.districtName,
        bnName: '',
      ),
      upazilla: detail.upazillaId != null
          ? Upazilla(
              id: detail.upazillaId!,
              name: detail.upazillaName ?? '',
              bnName: '',
            )
          : null,
      union: detail.unionId != null
          ? Union(id: detail.unionId!, name: detail.unionName ?? '', bnName: '')
          : null,
    );

    LocationSelection tempSelection = initialSelection;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderCtx, setDialogState) => AlertDialog(
          backgroundColor: _T.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Location',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _T.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(builderCtx).size.width * 0.9,
              child: LocationSelector(
                initialSelection: tempSelection,
                onSelectionChanged: (s) =>
                    setDialogState(() => tempSelection = s),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            _GhostBtn(
              label: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            BlocBuilder<OfficeDetailEditCubit, OfficeDetailEditState>(
              bloc: context.read<OfficeDetailEditCubit>(),
              builder: (_, editState) {
                final isLoading = editState is OfficeDetailEditLoadingState;
                return _BrandBtn(
                  label: 'Save',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          if (tempSelection.division == null ||
                              tempSelection.district == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select at least Division and District',
                                ),
                                backgroundColor: _T.warning,
                              ),
                            );
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          context.read<OfficeDetailEditCubit>().updateLocation(
                            useCase:
                                serviceLocator<UpdateOfficeLocationUseCase>(),
                            params: UpdateOfficeLocationPayload(
                              officeId: detail.id,
                              divisionId: tempSelection.division!.id,
                              districtId: tempSelection.district!.id,
                              upazillaId: tempSelection.upazilla?.id,
                              unionId: tempSelection.union?.id,
                            ),
                          );
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Contact card
// =============================================================================

class _ContactCard extends StatelessWidget {
  final OfficeDetail detail;
  final bool canEdit;

  const _ContactCard({required this.detail, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.phone,
            iconColor: _T.success,
            title: 'Contact',
            trailing: canEdit
                ? _EditIconButton(onPressed: () => _showEditDialog(context))
                : null,
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact Number',
              value: detail.contactNumber ?? 'Not provided',
              valueColor: detail.contactNumber == null ? _T.muted : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    // The dialog is completely dumb — no BlocBuilder inside it.
    // It returns the entered phone string, or null if cancelled.
    // The cubit is only called AFTER the dialog future resolves,
    // so the dialog's widget tree is fully gone before any state change occurs.
    final editCubit = context.read<OfficeDetailEditCubit>();

    final phone = await showDialog<String?>(
      context: context,
      builder: (dialogContext) =>
          _ContactEditDialog(initialValue: detail.contactNumber ?? ''),
    );

    // null means cancelled (dialog was dismissed without pressing Save)
    if (phone == null) return;

    editCubit.updateContact(
      useCase: serviceLocator<UpdateOfficeContactUseCase>(),
      params: UpdateOfficeContactPayload(
        officeId: detail.id,
        contactNumber: phone.isEmpty ? null : phone,
      ),
    );
  }
}

// =============================================================================
// Contact edit dialog — fully self-contained StatefulWidget.
// Owns its own TextEditingController so it is created and disposed within
// this widget's lifecycle. No BlocBuilder inside — returns the phone string
// (or null for cancel) via Navigator.pop so the caller can drive the cubit
// only after this widget's tree is completely gone.
// =============================================================================

class _ContactEditDialog extends StatefulWidget {
  final String initialValue;

  const _ContactEditDialog({required this.initialValue});

  @override
  State<_ContactEditDialog> createState() => _ContactEditDialogState();
}

class _ContactEditDialogState extends State<_ContactEditDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _T.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Update Contact Number',
        style: TextStyle(fontWeight: FontWeight.w700, color: _T.textPrimary),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _T.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Contact Number (Optional)',
            hintText: '01XXXXXXXXX',
            counterText: '',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.phone_outlined, color: _T.success, size: 20),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _T.brand, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) return null;
            if (val.trim().length != 11) {
              return 'Phone number must be exactly 11 digits';
            }
            return null;
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        _GhostBtn(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(null),
        ),
        _BrandBtn(
          label: 'Save',
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_ctrl.text.trim());
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Created At card
// =============================================================================

class _CreatedAtCard extends StatelessWidget {
  final DateTime createdAt;

  const _CreatedAtCard({required this.createdAt});

  String _age() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 365) {
      final y = (diff.inDays / 365).floor();
      return '$y year${y > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return '$m month${m > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    return 'Today';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          const _CardHeader(
            icon: Icons.calendar_today,
            iconColor: Color(0xFF8B5CF6),
            title: 'Created',
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.event,
                    label: 'Date',
                    value: DateFormat(
                      'MMM dd, yyyy',
                    ).format(createdAt.toLocal()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.timelapse,
                    label: 'Age',
                    value: _age(),
                    valueColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared small widgets
// =============================================================================

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _T.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LocationTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _T.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: _T.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _T.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _T.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: _T.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? _T.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditIconButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _T.brand.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.brand.withOpacity(0.2)),
        ),
        child: const Icon(Icons.edit_outlined, size: 16, color: _T.brand),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GhostBtn({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _T.textSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}

class _BrandBtn extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _BrandBtn({
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _T.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _T.muted,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox(
      width: 44,
      height: 44,
      child: CircularProgressIndicator(color: _T.brand, strokeWidth: 3),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Office',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _T.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: _T.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

// =============================================================================
// Entry animation
// =============================================================================

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
    begin: const Offset(0, 0.06),
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
