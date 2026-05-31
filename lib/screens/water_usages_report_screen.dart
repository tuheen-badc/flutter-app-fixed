import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/water_usages_report/water_usages_report_state.dart';
import '../common/bloc/water_usages_report/water_usages_report_state_cubit.dart';
import '../data/models/water_usages_report_criteria.dart';
import '../domain/usecases/water_usages_report.dart';
import '../presentation/drawer/role_based_drawer_screen.dart';

class WaterUsageReportScreen extends StatefulWidget {
  final User userData;
  final int? officeId;
  final int? pumpHouseId;
  final int? userId;

  const WaterUsageReportScreen({
    Key? key,
    required this.userData,
    this.officeId,
    this.pumpHouseId,
    this.userId,
  }) : super(key: key);

  @override
  State<WaterUsageReportScreen> createState() => _WaterUsageReportScreenState();
}

class _WaterUsageReportScreenState extends State<WaterUsageReportScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Optional filters - initialized from widget parameters
  late int? filterOfficeId;
  late int? filterPumpHouseId;
  late int? filterUserId;

  @override
  void initState() {
    super.initState();
    // Initialize filters from constructor parameters
    filterOfficeId = widget.officeId;
    filterPumpHouseId = widget.pumpHouseId;
    filterUserId = widget.userId;
  }

  bool get _hasActiveFilters =>
      filterOfficeId != null ||
      filterPumpHouseId != null ||
      filterUserId != null;

  String _getFilterSummary() {
    final filters = <String>[];
    if (filterOfficeId != null) filters.add('Office: $filterOfficeId');
    if (filterPumpHouseId != null)
      filters.add('Pump House: $filterPumpHouseId');
    if (filterUserId != null) filters.add('User: $filterUserId');
    return filters.join(' • ');
  }

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

  List<MonthData> _generateLast12Months() {
    final now = DateTime.now();
    final months = <MonthData>[];

    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMMM yyyy').format(date);
      final lastDay = DateTime(date.year, date.month + 1, 0).day;
      final startDate = DateFormat('MMM dd, yyyy').format(date);
      final endDate = DateFormat(
        'MMM dd, yyyy',
      ).format(DateTime(date.year, date.month, lastDay));

      months.add(
        MonthData(
          month: date.month,
          year: date.year,
          monthName: monthName,
          dateRange: '$startDate - $endDate',
        ),
      );
    }

    return months;
  }

  void _downloadReport(BuildContext context, MonthData monthData) {
    context.read<WaterUsageReportCubit>().downloadReport(
      useCase: serviceLocator<DownloadWaterUsageReportUseCase>(),
      params: WaterUsageReportCriteria(
        month: monthData.month,
        year: monthData.year,
        officeId: filterOfficeId,
        pumpHouseId: filterPumpHouseId,
        userId: filterUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = _generateLast12Months();

    return BlocProvider(
      create: (_) => WaterUsageReportCubit(),
      child: Builder(
        builder: (providerContext) {
          return BlocListener<WaterUsageReportCubit, WaterUsageReportState>(
            listener: (context, state) {
              if (state is WaterUsageReportSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report downloaded: ${state.fileName}'),
                    backgroundColor: _success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
                context.read<WaterUsageReportCubit>().resetState();
              } else if (state is WaterUsageReportErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: _danger,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
                context.read<WaterUsageReportCubit>().resetState();
              }
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: _bg,
              drawer: RoleBasedDrawer(
                userData: widget.userData,
                initialActiveItem: null, // Not a drawer menu item
              ),
              appBar: CustomTopBar(
                title: 'Water Usage Reports',
                onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              body: Column(
                children: [
                  // Filter Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(16),
                    decoration: _cardDecoration,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: _textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Download monthly water usage reports',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: _textPrimary,
                                ),
                              ),
                              if (_hasActiveFilters) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _getFilterSummary(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _brand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month Cards List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final monthData = months[index];
                        return _AnimatedIn(
                          delay: Duration(milliseconds: 30 * (index + 1)),
                          child: _buildMonthCard(providerContext, monthData),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthCard(BuildContext context, MonthData monthData) {
    return BlocBuilder<WaterUsageReportCubit, WaterUsageReportState>(
      builder: (context, state) {
        final isLoading =
            state is WaterUsageReportLoadingState &&
            state.month == monthData.month &&
            state.year == monthData.year;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLoading ? null : () => _downloadReport(context, monthData),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Calendar Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: _brand,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Month Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthData.monthName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          monthData.dateRange,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Download Button
                  if (isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: _brand,
                        strokeWidth: 2.5,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _brand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: _brand,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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

// Month data model
class MonthData {
  final int month;
  final int year;
  final String monthName;
  final String dateRange;

  MonthData({
    required this.month,
    required this.year,
    required this.monthName,
    required this.dateRange,
  });
}

// Animated fade-in widget
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
