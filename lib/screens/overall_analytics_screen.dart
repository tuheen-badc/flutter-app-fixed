// overall_analytics_screen.dart
import 'dart:math' as math;

import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/overall_ananlytics/overall_analytics_state_cubit.dart';
import '../common/bloc/overall_ananlytics/overall_ananlytics_state.dart';
import '../data/models/AnalyticsResponse.dart';
import '../domain/usecases/overall_analytics.dart';
import '../presentation/drawer/drawer_config.dart';

class OverallAnalyticsScreen extends StatefulWidget {
  final User userData;

  const OverallAnalyticsScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<OverallAnalyticsScreen> createState() => _OverallAnalyticsScreenState();
}

class _OverallAnalyticsScreenState extends State<OverallAnalyticsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Design tokens - matching the existing design system
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _info = Color(0xFF3182CE);

  void _loadAnalytics(BuildContext context) {
    context.read<OverallAnalyticsCubit>().loadAnalytics(
      useCase: serviceLocator<OverallAnalyticsUseCase>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OverallAnalyticsCubit()
            ..loadAnalytics(useCase: serviceLocator<OverallAnalyticsUseCase>()),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _bg,
        drawer: RoleBasedDrawer(
          userData: widget.userData,
          initialActiveItem: DrawerMenuItem.analytics,
        ),
        appBar: CustomTopBar(
          title: 'Overall Analytics',
          onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        body: BlocBuilder<OverallAnalyticsCubit, OverallAnalyticsState>(
          builder: (context, state) {
            if (state is OverallAnalyticsLoadingState) {
              return const _CenteredLoader();
            }

            if (state is OverallAnalyticsErrorState) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => _loadAnalytics(context),
              );
            }

            if (state is OverallAnalyticsLoadedState) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OverallAnalyticsCubit>().refresh(
                    useCase: serviceLocator<OverallAnalyticsUseCase>(),
                  );
                  // Wait a bit for the refresh
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: _brand,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Analytics Cards
                      _buildMainCards(state.analytics),
                      const SizedBox(height: 24),

                      // Pump Status Breakdown
                      _buildPumpStatusSection(state.analytics),
                      const SizedBox(height: 24),

                      // Circular Chart
                      _buildCircularChart(state.analytics),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }

            return const _CenteredLoader();
          },
        ),
      ),
    );
  }

  Widget _buildMainCards(AnalyticsResponse analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Pumps',
                value: analytics.totalPump.toString(),
                icon: Icons.water_damage,
                color: _info,
                bgColor: const Color(0xFFEBF8FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Users',
                value: analytics.totalUser.toString(),
                icon: Icons.people,
                color: _brand,
                bgColor: _brand.withOpacity(0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Running',
                value: analytics.runningPump.toString(),
                icon: Icons.play_circle_filled,
                color: _success,
                bgColor: const Color(0xFFD1FAE5),
                subtitle: '${analytics.runningPercentage.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Stopped',
                value: analytics.stoppedPump.toString(),
                icon: Icons.stop_circle,
                color: _danger,
                bgColor: const Color(0xFFFEE2E2),
                subtitle: '${analytics.stoppedPercentage.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPumpStatusSection(AnalyticsResponse analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pump Status Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'Running Pumps',
            value: analytics.runningPump,
            total: analytics.totalPump,
            color: _success,
            icon: Icons.play_circle_filled,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Stopped Pumps',
            value: analytics.stoppedPump,
            total: analytics.totalPump,
            color: _danger,
            icon: Icons.stop_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularChart(AnalyticsResponse analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        children: [
          const Text(
            'Pump Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular Chart
                _CircularChart(
                  runningPercentage: analytics.runningPercentage,
                  stoppedPercentage: analytics.stoppedPercentage,
                ),
                // Center Text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      analytics.totalPump.toString(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const Text(
                      'Total Pumps',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: _success,
                label: 'Running',
                value: analytics.runningPump,
              ),
              const SizedBox(width: 32),
              _LegendItem(
                color: _danger,
                label: 'Stopped',
                value: analytics.stoppedPump,
              ),
            ],
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _OverallAnalyticsScreenState._surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _OverallAnalyticsScreenState._border),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _OverallAnalyticsScreenState._textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _OverallAnalyticsScreenState._textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  final IconData icon;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _OverallAnalyticsScreenState._textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$value of $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _OverallAnalyticsScreenState._textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _OverallAnalyticsScreenState._border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircularChart extends StatelessWidget {
  final double runningPercentage;
  final double stoppedPercentage;

  const _CircularChart({
    required this.runningPercentage,
    required this.stoppedPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: _CircularChartPainter(
        runningPercentage: runningPercentage,
        stoppedPercentage: stoppedPercentage,
      ),
    );
  }
}

class _CircularChartPainter extends CustomPainter {
  final double runningPercentage;
  final double stoppedPercentage;

  _CircularChartPainter({
    required this.runningPercentage,
    required this.stoppedPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 28.0;

    // Background circle
    final bgPaint = Paint()
      ..color = _OverallAnalyticsScreenState._border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Running arc
    if (runningPercentage > 0) {
      final runningPaint = Paint()
        ..color = _OverallAnalyticsScreenState._success
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final runningAngle = (runningPercentage / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -math.pi / 2, // Start from top
        runningAngle,
        false,
        runningPaint,
      );
    }

    // Stopped arc
    if (stoppedPercentage > 0) {
      final stoppedPaint = Paint()
        ..color = _OverallAnalyticsScreenState._danger
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final runningAngle = (runningPercentage / 100) * 2 * math.pi;
      final stoppedAngle = (stoppedPercentage / 100) * 2 * math.pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -math.pi / 2 + runningAngle,
        stoppedAngle,
        false,
        stoppedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularChartPainter oldDelegate) {
    return oldDelegate.runningPercentage != runningPercentage ||
        oldDelegate.stoppedPercentage != stoppedPercentage;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _OverallAnalyticsScreenState._textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($value)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _OverallAnalyticsScreenState._textPrimary,
          ),
        ),
      ],
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
          color: _OverallAnalyticsScreenState._brand,
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
                color: _OverallAnalyticsScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _OverallAnalyticsScreenState._textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _OverallAnalyticsScreenState._brand,
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
