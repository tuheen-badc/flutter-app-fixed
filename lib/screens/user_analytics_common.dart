// user_analytics_content.dart
import 'package:demo_app/domain/usecases/pump_usages_analytics.dart';
import 'package:demo_app/service_locator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/user_specific_analytics/user_specific_analytics_state.dart';
import '../common/bloc/user_specific_analytics/user_specific_analytics_state_cubit.dart';
import '../data/models/usages_analytics.dart';

class UserAnalyticsContent extends StatefulWidget {
  final int userId;

  const UserAnalyticsContent({Key? key, required this.userId})
    : super(key: key);

  @override
  State<UserAnalyticsContent> createState() => _UserAnalyticsContentState();
}

class _UserAnalyticsContentState extends State<UserAnalyticsContent> {
  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _error = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);

  void _loadAnalytics(BuildContext ctx) {
    ctx.read<UserAnalyticsCubit>().loadUserAnalytics(
      useCase: serviceLocator<UserSpecificAnalyticsUseCase>(),
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserAnalyticsCubit()
        ..loadUserAnalytics(
          useCase: serviceLocator<UserSpecificAnalyticsUseCase>(),
          userId: widget.userId,
        ),
      child: Builder(
        builder: (providerContext) {
          return BlocBuilder<UserAnalyticsCubit, UserAnalyticsState>(
            builder: (context, state) {
              if (state is UserAnalyticsLoadingState) {
                return const _CenteredLoader();
              }

              if (state is UserAnalyticsErrorState) {
                return _ErrorView(
                  message: state.errorMessage,
                  onRetry: () => _loadAnalytics(providerContext),
                );
              }

              if (state is UserAnalyticsLoadedState) {
                return RefreshIndicator(
                  onRefresh: () async => _loadAnalytics(providerContext),
                  color: _brand,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Summary Section
                        const Text(
                          'Transaction Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionSummaryCards(
                          state.analyticsData.transactionSummary,
                        ),

                        const SizedBox(height: 32),

                        // Water Usage Analytics Section
                        const Text(
                          'Water Usage Analytics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Last 6 months usage trends',
                          style: TextStyle(fontSize: 13, color: _textSecondary),
                        ),
                        const SizedBox(height: 16),
                        _buildUsageAnalyticsChart(
                          state.analyticsData.usagesAnalytics,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const _CenteredLoader();
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionSummaryCards(transactionSummary) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 2);
    final balance = transactionSummary.balance;
    final hasPositiveBalance = transactionSummary.hasPositiveBalance;

    return Column(
      children: [
        // Credit and Debit Row
        Row(
          children: [
            // Total Credit Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _success.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _success.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: _success,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Credit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormat.format(transactionSummary.totalCredit),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _success,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 12,
                            color: _success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recharged',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Total Debit Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _error.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _error.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: _error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Debit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormat.format(transactionSummary.totalDebit),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _error,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 12,
                            color: _error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Spent',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageAnalyticsChart(List<UsageAnalytics> usagesAnalytics) {
    if (usagesAnalytics.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration,
        child: const Center(
          child: Text(
            'No usage data available',
            style: TextStyle(fontSize: 14, color: _textSecondary),
          ),
        ),
      );
    }

    // Calculate percentage change
    String percentageChange = '+0.0%';
    Color changeColor = _success;

    if (usagesAnalytics.length >= 2) {
      final current = usagesAnalytics.last.totalUsages.toDouble();
      final previous = usagesAnalytics[usagesAnalytics.length - 2].totalUsages
          .toDouble();

      if (previous != 0) {
        final change = ((current - previous) / previous) * 100;
        percentageChange =
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
        changeColor = change >= 0 ? _success : _error;
      } else if (current > 0) {
        percentageChange = '+100.0%';
        changeColor = _success;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Usage Trends',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentageChange,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: changeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _UsageAnalyticsBarChart(data: usagesAnalytics),
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

// ============================================================================
// USAGE ANALYTICS BAR CHART
// ============================================================================

class _UsageAnalyticsBarChart extends StatelessWidget {
  final List<UsageAnalytics> data;

  const _UsageAnalyticsBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxUsage = data
        .map((e) => e.totalUsages)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final minUsage = data
        .map((e) => e.totalUsages)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxUsage > 0 ? maxUsage * 1.2 : 10,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2D3748),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[groupIndex].monthName} ${data[groupIndex].year}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} usages',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].chartLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF718096),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF718096),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxUsage > 0 ? maxUsage / 4 : 2.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.totalUsages.toDouble(),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3182CE), Color(0xFF2563EB)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

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
