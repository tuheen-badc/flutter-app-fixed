// tabs/pump_history.dart
import 'package:demo_app/common/bloc/single_pump_station_history/single_pump_station_history_state.dart';
import 'package:demo_app/data/models/pump_station_history.dart';
import 'package:demo_app/data/models/single_pump_station_history_criteria.dart';
import 'package:demo_app/presentation/pump_tabs/tab_design_tokens.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/single_pump_station_history/single_pump_station_history_state_cubit.dart';
import '../../domain/usecases/single_pump_station_history.dart';

class HistoryTab extends StatefulWidget {
  final int pumpStationId;

  const HistoryTab({Key? key, required this.pumpStationId}) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final TextEditingController _phoneController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;
  int currentPage = 0;
  final int pageSize = 20;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadHistory(BuildContext ctx) {
    ctx.read<SinglePumpStationHistoryCubit>().loadSinglePumpStationHistory(
      useCase: serviceLocator<SinglePumpStationHistoryUseCase>(),
      params: SinglePumpStationHistoryParam(
        pumpStationId: widget.pumpStationId,
        page: currentPage,
        size: pageSize,
        userPhone: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  void _showFilterDialog(BuildContext providerContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        DateTime? tempFromDate = fromDate;
        DateTime? tempToDate = toDate;
        String tempPhone = _phoneController.text;

        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: DesignTokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter History',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Phone Filter
                      const Text(
                        'User Phone',
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
                      const SizedBox(height: 20),

                      // Date Range Filter
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DatePickerField(
                        label: 'From Date',
                        value: tempFromDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: builderContext,
                            initialDate: tempFromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: DesignTokens.brand,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setDialogState(() => tempFromDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _DatePickerField(
                        label: 'To Date',
                        value: tempToDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: builderContext,
                            initialDate: tempToDate ?? DateTime.now(),
                            firstDate: tempFromDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: DesignTokens.brand,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setDialogState(() => tempToDate = picked);
                          }
                        },
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
                TextButton(
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      _phoneController.clear();
                      fromDate = null;
                      toDate = null;
                      currentPage = 0;
                    });
                    _loadHistory(providerContext);
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
                  onPressed: () => Navigator.of(builderContext).pop(),
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
                    Navigator.of(builderContext).pop();
                    setState(() {
                      _phoneController.text = tempPhone;
                      fromDate = tempFromDate;
                      toDate = tempToDate;
                      currentPage = 0;
                    });
                    _loadHistory(providerContext);
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
      },
    );
  }

  void _goToPage(int page, BuildContext ctx) {
    setState(() => currentPage = page);
    _loadHistory(ctx);
  }

  String _getFilterSummary() {
    List<String> filters = [];

    if (_phoneController.text.isNotEmpty) {
      filters.add('Phone: ${_phoneController.text}');
    }

    if (fromDate != null && toDate != null) {
      filters.add(
        '${DateFormat('MMM dd').format(fromDate!)} - ${DateFormat('MMM dd, yyyy').format(toDate!)}',
      );
    }

    return filters.isEmpty ? 'All Water Supply Sessions' : filters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SinglePumpStationHistoryCubit()..loadSinglePumpStationHistory(
            useCase: serviceLocator<SinglePumpStationHistoryUseCase>(),
            params: SinglePumpStationHistoryParam(
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

              // History List
              Expanded(
                child:
                    BlocBuilder<
                      SinglePumpStationHistoryCubit,
                      SinglePumpStationHistoryState
                    >(
                      builder: (context, state) {
                        if (state is SinglePumpStationHistoryLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: DesignTokens.brand,
                              strokeWidth: 3,
                            ),
                          );
                        }

                        if (state is SinglePumpStationHistoryErrorState) {
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
                                    'Error Loading History',
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
                                    onPressed: () =>
                                        _loadHistory(providerContext),
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

                        if (state is SinglePumpStationHistoryLoadedState) {
                          if (state.historyList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.water_damage_outlined,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Water Supply History',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Water supply sessions will appear here',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // List Items
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    _loadHistory(providerContext);
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: state.historyList.length,
                                    itemBuilder: (context, index) {
                                      final item = state.historyList[index];
                                      return _AnimatedIn(
                                        delay: Duration(
                                          milliseconds: 40 * (index + 1),
                                        ),
                                        child: _buildHistoryCard(item),
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
                                      top: BorderSide(
                                        color: DesignTokens.border,
                                      ),
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                            state.currentPage <
                                                state.totalPages - 1
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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

  Widget _buildHistoryCard(PumpStationHistoryItem item) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: DesignTokens.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DesignTokens.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName,
                          style: const TextStyle(
                            fontSize: 15,
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
                              item.userPhone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: DesignTokens.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Duration Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.brand.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DesignTokens.brand.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: DesignTokens.brand,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.durationFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Divider
            const Divider(color: DesignTokens.border, height: 1),

            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DesignTokens.info.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          color: DesignTokens.info,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Volume',
                          style: TextStyle(
                            fontSize: 11,
                            color: DesignTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.volumeSupplied.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DesignTokens.accent.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: DesignTokens.accent,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cost',
                          style: TextStyle(
                            fontSize: 11,
                            color: DesignTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(item.balanceDeducted),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Time Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Started: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(item.startedAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.stop_circle_outlined,
                        size: 16,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ended: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(item.endedAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // End Reason
            if (item.endReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DesignTokens.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: DesignTokens.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.endReason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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
          border: Border.all(color: DesignTokens.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: DesignTokens.brand,
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
                      color: DesignTokens.textSecondary,
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
                          ? DesignTokens.textPrimary
                          : DesignTokens.muted,
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
