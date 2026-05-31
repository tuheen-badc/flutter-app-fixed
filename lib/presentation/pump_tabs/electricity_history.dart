// user_electricity_history_tab.dart

import 'package:demo_app/common/bloc/electricity_history/electricity_history_state.dart';
import 'package:demo_app/data/models/electricity_history_criteria.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/electricity_history/electricity_history_state_cubit.dart';
import '../../data/models/electricity_history.dart';
import '../../domain/usecases/electricity_history.dart';

class UserElectricityHistoryTab extends StatelessWidget {
  final int pumpStationId;

  const UserElectricityHistoryTab({Key? key, required this.pumpStationId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ElectricityHistoryContent(pumpStationId: pumpStationId);
  }
}

// ============================================================================
// CONTENT
// ============================================================================

class _ElectricityHistoryContent extends StatefulWidget {
  final int pumpStationId;

  const _ElectricityHistoryContent({required this.pumpStationId});

  @override
  State<_ElectricityHistoryContent> createState() =>
      _ElectricityHistoryContentState();
}

class _ElectricityHistoryContentState
    extends State<_ElectricityHistoryContent> {
  DateTime? fromDate;
  DateTime? toDate;
  int currentPage = 0;
  final int pageSize = 20;

  // Design tokens — identical to the rest of the project
  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);

  void _loadHistory(BuildContext ctx) {
    ctx.read<ElectricityHistoryCubit>().loadElectricityHistory(
      useCase: serviceLocator<ElectricityHistoryUseCase>(),
      params: ElectricityHistoryCriteria(
        pumpStationId: widget.pumpStationId,
        page: currentPage,
        size: pageSize,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  void _showDateFilterDialog(BuildContext providerContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        DateTime? tempFrom = fromDate;
        DateTime? tempTo = toDate;

        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter by Date',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DatePickerField(
                    label: 'From Date',
                    value: tempFrom,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: tempFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: _brand,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => tempFrom = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _DatePickerField(
                    label: 'To Date',
                    value: tempTo,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: tempTo ?? DateTime.now(),
                        firstDate: tempFrom ?? DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: _brand,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => tempTo = picked);
                      }
                    },
                  ),
                ],
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
                      fromDate = null;
                      toDate = null;
                      currentPage = 0;
                    });
                    _loadHistory(providerContext);
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
                      fromDate = tempFrom;
                      toDate = tempTo;
                      currentPage = 0;
                    });
                    _loadHistory(providerContext);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goToPage(int page, BuildContext ctx) {
    setState(() => currentPage = page);
    _loadHistory(ctx);
  }

  String _filterLabel() {
    if (fromDate != null && toDate != null) {
      return '${DateFormat('MMM dd').format(fromDate!)} – '
          '${DateFormat('MMM dd, yyyy').format(toDate!)}';
    }
    if (fromDate != null) {
      return 'From ${DateFormat('MMM dd, yyyy').format(fromDate!)}';
    }
    if (toDate != null) {
      return 'Until ${DateFormat('MMM dd, yyyy').format(toDate!)}';
    }
    return 'All Records';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ElectricityHistoryCubit()
        ..loadElectricityHistory(
          useCase: serviceLocator<ElectricityHistoryUseCase>(),
          params: ElectricityHistoryCriteria(
            pumpStationId: widget.pumpStationId,
            page: currentPage,
            size: pageSize,
          ),
        ),
      child: Builder(
        builder: (providerContext) {
          return Column(
            children: [
              // ── Filter Bar ──────────────────────────────────────────────
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
                        _filterLabel(),
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
                      onPressed: () => _showDateFilterDialog(providerContext),
                      dense: true,
                    ),
                  ],
                ),
              ),

              // ── List ────────────────────────────────────────────────────
              Expanded(
                child:
                    BlocBuilder<
                      ElectricityHistoryCubit,
                      ElectricityHistoryState
                    >(
                      builder: (context, state) {
                        if (state is ElectricityHistoryLoadingState) {
                          return const _CenteredLoader();
                        }

                        if (state is ElectricityHistoryErrorState) {
                          return _ErrorView(
                            message: state.errorMessage,
                            onRetry: () => _loadHistory(providerContext),
                          );
                        }

                        if (state is ElectricityHistoryLoadedState) {
                          if (state.historyList.isEmpty) {
                            return const _EmptyView();
                          }

                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: state.historyList.length,
                                  itemBuilder: (context, index) {
                                    return _AnimatedIn(
                                      delay: Duration(
                                        milliseconds: 40 * (index + 1),
                                      ),
                                      child: _ElectricityHistoryCard(
                                        item: state.historyList[index],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Pagination
                              if (state.totalPages > 1)
                                _PaginationBar(
                                  current: state.currentPage + 1,
                                  total: state.totalPages,
                                  onPrev: state.currentPage > 0
                                      ? () => _goToPage(
                                          state.currentPage - 1,
                                          providerContext,
                                        )
                                      : null,
                                  onNext:
                                      state.currentPage < state.totalPages - 1
                                      ? () => _goToPage(
                                          state.currentPage + 1,
                                          providerContext,
                                        )
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
          );
        },
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

// ============================================================================
// ELECTRICITY HISTORY CARD
// ============================================================================

class _ElectricityHistoryCard extends StatelessWidget {
  final ElectricityStatusHistoryItem item;

  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);

  const _ElectricityHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ────────────────────────────────────────────────
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    color: _brand,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Electricity Status',
                        style: TextStyle(
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
                            Icons.access_time,
                            size: 13,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(item.loggedAt.toLocal()),
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            const Divider(color: _border, height: 1),

            const SizedBox(height: 16),

            // ── Phase Status Row (matching ElectricityAvailabilityScreen style) ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPhaseIndicator('Phase 1', item.phaseOneAvailable),
                  _buildPhaseIndicator('Phase 2', item.phaseTwoAvailable),
                  _buildPhaseIndicator('Phase 3', item.phaseThreeAvailable),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(String label, bool isAvailable) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAvailable ? _success : _danger,
            boxShadow: [
              BoxShadow(
                color: isAvailable
                    ? _success.withOpacity(0.3)
                    : _danger.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: TextStyle(
            fontSize: 10,
            color: isAvailable ? _success : _danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

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

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF3182CE),
              size: 20,
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
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? DateFormat('MMM dd, yyyy').format(value!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value != null
                          ? const Color(0xFF2D3748)
                          : const Color(0xFFA0AEC0),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            Icon(
              Icons.electrical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Electricity Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Electricity history will appear here',
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
              'Error Loading Records',
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
            _BrandButton(label: 'Retry', onPressed: onRetry),
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
        color: const Color(0xFFFFFFFF),
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
