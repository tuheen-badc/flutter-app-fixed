// presentation/pump_tabs/pump_details_tab.dart

// presentation/pump_tabs/pump_details_tab.dart

import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/pump_station_detail/pump_station_detail_edit_state.dart';
import '../../common/bloc/pump_station_detail/pump_station_detail_edit_state_cubit.dart';
import '../../common/bloc/pump_station_detail/pump_station_detail_state.dart';
import '../../common/bloc/pump_station_detail/pump_station_detail_state_cubit.dart';
import '../../data/models/pump_station_detail.dart';
import '../../data/models/pump_station_update_payload.dart';
import '../../domain/usecases/pump_station_detail.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (kept local so the tab is self-contained)
// ─────────────────────────────────────────────────────────────────────────────
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
// Entry-point widget
// =============================================================================

class PumpDetailsTab extends StatelessWidget {
  final int pumpStationId;

  /// Caller must pass the logged-in user's role so the tab can adapt its UI.
  final UserRole userRole;

  const PumpDetailsTab({
    Key? key,
    required this.pumpStationId,
    required this.userRole,
  }) : super(key: key);

  bool get _canEdit =>
      userRole == UserRole.ADMIN || userRole == UserRole.SUPER_ADMIN;

  bool get _isSuperAdmin => userRole == UserRole.SUPER_ADMIN;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PumpDetailViewCubit()
            ..loadDetail(
              useCase: serviceLocator<GetPumpStationDetailViewUseCase>(),
              pumpStationId: pumpStationId,
            ),
        ),
        BlocProvider(create: (_) => PumpDetailEditCubit()),
      ],
      child: Builder(
        builder: (ctx) =>
            BlocListener<PumpDetailEditCubit, PumpDetailEditState>(
              listener: (context, editState) {
                if (editState is PumpDetailEditSuccessState) {
                  // Patch the view cubit with the freshly returned detail
                  final viewCubit = context.read<PumpDetailViewCubit>();
                  final current = viewCubit.state;
                  if (current is PumpDetailViewLoadedState) {
                    viewCubit.emit(
                      current.copyWith(detail: editState.updatedDetail),
                    );
                  }
                  context.read<PumpDetailEditCubit>().resetState();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Updated successfully'),
                      backgroundColor: _T.success,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (editState is PumpDetailEditErrorState) {
                  context.read<PumpDetailEditCubit>().resetState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editState.errorMessage),
                      backgroundColor: _T.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<PumpDetailViewCubit, PumpDetailViewState>(
                builder: (context, state) {
                  if (state is PumpDetailViewLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _T.brand,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (state is PumpDetailViewErrorState) {
                    return _ErrorView(
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<PumpDetailViewCubit>().loadDetail(
                            useCase:
                                serviceLocator<
                                  GetPumpStationDetailViewUseCase
                                >(),
                            pumpStationId: pumpStationId,
                          ),
                    );
                  }

                  if (state is PumpDetailViewLoadedState) {
                    return _DetailBody(
                      detail: state.detail,
                      pumpStationId: pumpStationId,
                      canEdit: _canEdit,
                      isSuperAdmin: _isSuperAdmin,
                      onRefresh: () =>
                          context.read<PumpDetailViewCubit>().refresh(
                            useCase:
                                serviceLocator<
                                  GetPumpStationDetailViewUseCase
                                >(),
                            pumpStationId: pumpStationId,
                          ),
                    );
                  }

                  return const SizedBox.shrink();
                },
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
  final PumpStationDetailView detail;
  final int pumpStationId;
  final bool canEdit;
  final bool isSuperAdmin;
  final VoidCallback onRefresh;

  const _DetailBody({
    required this.detail,
    required this.pumpStationId,
    required this.canEdit,
    required this.isSuperAdmin,
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
          // ── Location card ───────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 70),
            child: _LocationCard(
              detail: detail,
              pumpStationId: pumpStationId,
              canEdit: canEdit,
            ),
          ),
          const SizedBox(height: 16),

          // ── Office card ─────────────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 110),
            child: _OfficeCard(detail: detail),
          ),
          const SizedBox(height: 16),

          // ── Installation card ───────────────────────────────────────────
          _AnimatedIn(
            delay: const Duration(milliseconds: 150),
            child: _InstallationCard(installationDate: detail.installationDate),
          ),
          const SizedBox(height: 16),

          // ── Manager card (ADMIN / SUPER_ADMIN) ──────────────────────────
          if (detail.hasManagerInfo) ...[
            _AnimatedIn(
              delay: const Duration(milliseconds: 190),
              child: _ManagerCard(
                detail: detail,
                pumpStationId: pumpStationId,
                canEdit: canEdit,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Data provider card (SUPER_ADMIN) ────────────────────────────
          if (detail.hasDataProviderInfo && isSuperAdmin) ...[
            _AnimatedIn(
              delay: const Duration(milliseconds: 230),
              child: _DataProviderCard(
                detail: detail,
                pumpStationId: pumpStationId,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Station name header
// =============================================================================

class _NameHeader extends StatelessWidget {
  final String name;

  const _NameHeader({required this.name});

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
            child: const Icon(Icons.water_damage, color: _T.brand, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pump Station',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _T.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                    letterSpacing: 0.2,
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
// Location card  (edit only for ADMIN / SUPER_ADMIN)
// =============================================================================

class _LocationCard extends StatelessWidget {
  final PumpStationDetailView detail;
  final int pumpStationId;
  final bool canEdit;

  const _LocationCard({
    required this.detail,
    required this.pumpStationId,
    required this.canEdit,
  });

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
    // Pre-build initial selection using the current IDs from the detail
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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
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
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: LocationSelector(
                    initialSelection: tempSelection,
                    onSelectionChanged: (selection) {
                      setDialogState(() => tempSelection = selection);
                    },
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
                BlocBuilder<PumpDetailEditCubit, PumpDetailEditState>(
                  bloc: context.read<PumpDetailEditCubit>(),
                  builder: (_, editState) {
                    final isLoading = editState is PumpDetailEditLoadingState;
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
                                      'Please select at least division and district',
                                    ),
                                    backgroundColor: _T.warning,
                                  ),
                                );
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              context
                                  .read<PumpDetailEditCubit>()
                                  .updateLocation(
                                    useCase:
                                        serviceLocator<
                                          UpdatePumpLocationUseCase
                                        >(),
                                    params: UpdatePumpLocationPayload(
                                      pumpStationId: pumpStationId,
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
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Office card
// =============================================================================

class _OfficeCard extends StatelessWidget {
  final PumpStationDetailView detail;

  const _OfficeCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          const _CardHeader(
            icon: Icons.business,
            iconColor: Colors.indigo,
            title: 'Office',
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _LocationTile(
              icon: Icons.apartment,
              label: 'Office Name',
              value: detail.officeName,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Installation card
// =============================================================================

class _InstallationCard extends StatelessWidget {
  final DateTime installationDate;

  const _InstallationCard({required this.installationDate});

  String _age() {
    final diff = DateTime.now().difference(installationDate);
    if (diff.inDays < 1) return 'Installed today';
    if (diff.inDays < 30) return '${diff.inDays} days old';
    if (diff.inDays < 365) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} old';
    }
    final y = (diff.inDays / 365).floor();
    final rm = ((diff.inDays % 365) / 30).floor();
    return rm == 0
        ? '$y ${y == 1 ? 'year' : 'years'} old'
        : '$y ${y == 1 ? 'year' : 'years'}, $rm ${rm == 1 ? 'month' : 'months'} old';
  }

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
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Installation Date',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _T.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(installationDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _age(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
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
// Manager card  (ADMIN / SUPER_ADMIN)
// =============================================================================

class _ManagerCard extends StatelessWidget {
  final PumpStationDetailView detail;
  final int pumpStationId;
  final bool canEdit;

  const _ManagerCard({
    required this.detail,
    required this.pumpStationId,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.person,
            iconColor: Colors.green,
            title: 'Manager',
            trailing: canEdit
                ? _EditIconButton(onPressed: () => _showEditDialog(context))
                : null,
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Manager name row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager Name',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _T.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail.managerName ?? '—',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _T.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Phone number row
                _PhoneRow(
                  phone: detail.managerPhone ?? '—',
                  accentColor: _T.brand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: detail.managerPhone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _T.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone, color: Colors.green, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Change Manager',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _T.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: _PhoneInputField(
            controller: controller,
            label: 'Manager Phone Number',
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
            BlocBuilder<PumpDetailEditCubit, PumpDetailEditState>(
              bloc: context.read<PumpDetailEditCubit>(),
              builder: (_, editState) {
                final isLoading = editState is PumpDetailEditLoadingState;
                return _BrandBtn(
                  label: 'Save',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          final phone = controller.text.trim();
                          if (phone.isEmpty) return;
                          Navigator.of(dialogContext).pop();
                          context
                              .read<PumpDetailEditCubit>()
                              .updateManagerPhone(
                                useCase:
                                    serviceLocator<UpdateManagerPhoneUseCase>(),
                                params: UpdateManagerPhonePayload(
                                  pumpStationId: pumpStationId,
                                  managerPhone: phone,
                                ),
                              );
                        },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Data provider card  (SUPER_ADMIN only)
// =============================================================================

class _DataProviderCard extends StatelessWidget {
  final PumpStationDetailView detail;
  final int pumpStationId;

  const _DataProviderCard({required this.detail, required this.pumpStationId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _T.card,
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.cell_tower,
            iconColor: Colors.purple,
            title: 'Data Provider',
            trailing: _EditIconButton(
              onPressed: () => _showEditDialog(context),
            ),
          ),
          const Divider(height: 1, color: _T.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _PhoneRow(
              phone: detail.dataProviderPhone ?? '—',
              accentColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: detail.dataProviderPhone ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _T.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cell_tower,
                  color: Colors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Update Data Provider',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _T.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: _PhoneInputField(
            controller: controller,
            label: 'Data Provider Phone',
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
            BlocBuilder<PumpDetailEditCubit, PumpDetailEditState>(
              bloc: context.read<PumpDetailEditCubit>(),
              builder: (_, editState) {
                final isLoading = editState is PumpDetailEditLoadingState;
                return _BrandBtn(
                  label: 'Save',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          final phone = controller.text.trim();
                          if (phone.isEmpty) return;
                          Navigator.of(dialogContext).pop();
                          context
                              .read<PumpDetailEditCubit>()
                              .updateDataProviderPhone(
                                useCase:
                                    serviceLocator<
                                      UpdateDataProviderPhoneUseCase
                                    >(),
                                params: UpdateDataProviderPhonePayload(
                                  pumpStationId: pumpStationId,
                                  dataProviderPhone: phone,
                                ),
                              );
                        },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Reusable helper widgets
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
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _T.textPrimary,
                letterSpacing: 0.3,
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

class _PhoneRow extends StatelessWidget {
  final String phone;
  final Color accentColor;

  const _PhoneRow({required this.phone, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.phone, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _T.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Copy number',
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () {
                Clipboard.setData(ClipboardData(text: phone));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number copied'),
                    backgroundColor: _T.success,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.copy, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PhoneInputField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      autofocus: true,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _T.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'e.g. 01XXXXXXXXX',
        prefixIcon: const Icon(Icons.phone, color: _T.brand, size: 20),
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
    );
  }
}

class _EditIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditIconButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Edit',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _T.brand.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _T.brand.withOpacity(0.2)),
          ),
          child: const Icon(Icons.edit_outlined, color: _T.brand, size: 18),
        ),
      ),
    );
  }
}

class _BrandBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _BrandBtn({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _T.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        disabledBackgroundColor: _T.muted,
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
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

// =============================================================================
// Error view
// =============================================================================

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
              'Error Loading Details',
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
            _BrandBtn(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Entry animation (fade + slight upward slide)
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
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .07),
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
