// tabs/pump_analytics_tab.dart
import 'package:demo_app/data/models/pump_analytics_response.dart';
import 'package:demo_app/presentation/pump_tabs/tab_design_tokens.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/pump_analytics/pump_analytics_state.dart';
import '../../common/bloc/pump_analytics/pump_analytics_state_cubit.dart';
import '../../domain/usecases/pump_analytics.dart';

class PumpAnalyticsTab extends StatefulWidget {
  final int pumpStationId;

  const PumpAnalyticsTab({Key? key, required this.pumpStationId})
    : super(key: key);

  @override
  State<PumpAnalyticsTab> createState() => _PumpAnalyticsTabState();
}

class _PumpAnalyticsTabState extends State<PumpAnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PumpAnalyticsCubit()
        ..loadAnalytics(
          useCase: serviceLocator<PumpAnalyticsUseCase>(),
          params: widget.pumpStationId,
        ),
      child: Builder(builder: (context) => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PumpAnalyticsCubit, PumpAnalyticsState>(
      builder: (context, state) {
        if (state is PumpAnalyticsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: DesignTokens.brand,
              strokeWidth: 3,
            ),
          );
        }

        if (state is PumpAnalyticsErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Analytics',
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
                    onPressed: () {
                      context.read<PumpAnalyticsCubit>().loadAnalytics(
                        useCase: serviceLocator<PumpAnalyticsUseCase>(),
                        params: widget.pumpStationId,
                      );
                    },
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

        if (state is PumpAnalyticsLoadedState) {
          return _AnalyticsContent(
            analytics: state.analytics,
            onRefresh: () {
              context.read<PumpAnalyticsCubit>().loadAnalytics(
                useCase: serviceLocator<PumpAnalyticsUseCase>(),
                params: widget.pumpStationId,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ── Analytics content ─────────────────────────────────────────────────────────

class _AnalyticsContent extends StatelessWidget {
  final PumpAnalyticsResponse analytics;
  final VoidCallback onRefresh;

  const _AnalyticsContent({required this.analytics, required this.onRefresh});

  static const _purple = Color(0xFF8B5CF6);
  static const _cyan = Color(0xFF06B6D4);
  static const _warning = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '৳', decimalDigits: 2);
    final number = NumberFormat('#,##0.##');

    final totalMinutes = (analytics.totalOperatedHours * 60).round();
    final displayHours = totalMinutes ~/ 60;
    final displayMinutes = totalMinutes % 60;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Operated Hours ───────────────────────────────────────────
            _MetricCard(
              icon: Icons.access_time_filled,
              color: _purple,
              title: 'Total Operated Hours',
              mainValue: '$displayHours hrs $displayMinutes min',
              rows: [
                _RowData(label: 'Hours', value: displayHours.toString()),
                _RowData(label: 'Minutes', value: displayMinutes.toString()),
              ],
            ),

            const SizedBox(height: 14),

            // ── Supplied Volume ──────────────────────────────────────────
            _MetricCard(
              icon: Icons.opacity,
              color: _cyan,
              title: 'Supplied Volume',
              mainValue: '${number.format(analytics.suppliedVolume)} L',
              rows: [
                _RowData(
                  label: 'Litres',
                  value: number.format(analytics.suppliedVolume),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Deducted Amount ──────────────────────────────────────────
            _MetricCard(
              icon: Icons.account_balance_wallet_outlined,
              color: _warning,
              title: 'Deducted Amount',
              mainValue: currency.format(analytics.deductedAmount),
              rows: [
                _RowData(
                  label: 'Total Amount',
                  value: currency.format(analytics.deductedAmount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String mainValue;
  final List<_RowData> rows;

  const _MetricCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.mainValue,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: DesignTokens.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mainValue,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Rows (only shown if more than one value to break down)
          if (rows.length > 1) ...[
            const SizedBox(height: 14),
            const Divider(color: DesignTokens.border, height: 1),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: DesignTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      row.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RowData {
  final String label;
  final String value;

  const _RowData({required this.label, required this.value});
}
