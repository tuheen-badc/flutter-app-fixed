// screens/office_analytics_screen.dart
import 'package:demo_app/data/models/office_analytics_response.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/bloc/office_analytics/office_analytics_state.dart';
import '../../common/bloc/office_analytics/office_analytics_state_cubit.dart';
import '../../domain/usecases/office_analytics.dart';

class OfficeAnalyticsScreen extends StatefulWidget {
  final int officeId;
  final String officeName;

  const OfficeAnalyticsScreen({
    Key? key,
    required this.officeId,
    required this.officeName,
  }) : super(key: key);

  @override
  State<OfficeAnalyticsScreen> createState() => _OfficeAnalyticsScreenState();
}

class _OfficeAnalyticsScreenState extends State<OfficeAnalyticsScreen> {
  // Design tokens
  static const _bg = Color(0xFFF8F9FA);
  static const _brand = Color(0xFF3182CE);

  late final OfficeAnalyticsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = OfficeAnalyticsCubit()
      ..loadAnalytics(
        useCase: serviceLocator<OfficeAnalyticsUseCase>(),
        params: widget.officeId,
      );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _reload() {
    _cubit.loadAnalytics(
      useCase: serviceLocator<OfficeAnalyticsUseCase>(),
      params: widget.officeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _brand,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reload,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocBuilder<OfficeAnalyticsCubit, OfficeAnalyticsState>(
          builder: (context, state) {
            if (state is OfficeAnalyticsLoadingState) {
              return const _CenteredLoader();
            }
            if (state is OfficeAnalyticsErrorState) {
              return _ErrorView(message: state.errorMessage, onRetry: _reload);
            }
            if (state is OfficeAnalyticsLoadedState) {
              return _AnalyticsBody(
                analytics: state.analytics,
                onRefresh: _reload,
              );
            }
            return const _CenteredLoader();
          },
        ),
      ),
    );
  }
}

// ── Analytics Body ────────────────────────────────────────────────────────────

class _AnalyticsBody extends StatelessWidget {
  final OfficeAnalyticsResponse analytics;
  final VoidCallback onRefresh;

  const _AnalyticsBody({required this.analytics, required this.onRefresh});

  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _brand = Color(0xFF3182CE);
  static const _purple = Color(0xFF8B5CF6);
  static const _cyan = Color(0xFF06B6D4);
  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '৳', decimalDigits: 2);
    final number = NumberFormat('#,##0.##');

    final stoppedPumps = analytics.totalPump - analytics.totalRunningPump;
    final runningRatio = analytics.totalPump > 0
        ? analytics.totalRunningPump / analytics.totalPump
        : 0.0;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pump Status Card (hero banner) ──────────────────────────
            _SectionTitle(title: 'Pump Status'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B6CB0), Color(0xFF3182CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _brand.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _BannerStat(
                        icon: Icons.water_drop_outlined,
                        label: 'Total',
                        value: analytics.totalPump.toString(),
                      ),
                      const SizedBox(width: 10),
                      _BannerStat(
                        icon: Icons.play_circle_fill,
                        label: 'Running',
                        value: analytics.totalRunningPump.toString(),
                        valueColor: const Color(0xFF6EE7B7),
                      ),
                      const SizedBox(width: 10),
                      _BannerStat(
                        icon: Icons.stop_circle_outlined,
                        label: 'Stopped',
                        value: stoppedPumps.toString(),
                        valueColor: const Color(0xFFFCA5A5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active pumps',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(runningRatio * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: runningRatio,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6EE7B7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Operations ──────────────────────────────────────────────
            _SectionTitle(title: 'Operations'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.opacity,
                    label: 'Supplied Volume',
                    value: number.format(analytics.suppliedVolume),
                    unit: 'Litres',
                    color: _cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.access_time_filled,
                    label: 'Operated Hours',
                    value: number.format(analytics.totalOperatedHours),
                    unit: 'Hours',
                    color: _purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Financials ──────────────────────────────────────────────
            _SectionTitle(title: 'Financials'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Deducted Amount',
                    value: currency.format(analytics.deductedAmount),
                    color: _warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.trending_down_rounded,
                    label: 'Total Debit',
                    value: currency.format(analytics.totalDebitAmount),
                    color: _danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── People ──────────────────────────────────────────────────
            _SectionTitle(title: 'People'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people_alt_outlined,
                    label: 'Total Users',
                    value: analytics.totalUser.toString(),
                    color: _success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Total Admins',
                    value: analytics.totalAdmin.toString(),
                    color: _orange,
                  ),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF718096),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _BannerStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.85)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              letterSpacing: 0.1,
            ),
          ),
          if (unit != null) ...[
            const SizedBox(height: 2),
            Text(
              unit!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF718096),
            ),
          ),
        ],
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
      child: CircularProgressIndicator(
        color: Color(0xFF3182CE),
        strokeWidth: 3,
      ),
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
            'Error Loading Analytics',
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
