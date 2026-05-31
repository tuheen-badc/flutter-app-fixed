// pump_tabs_container.dart
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/pump_tabs/electricity_history.dart';
import 'package:demo_app/presentation/pump_tabs/pump_analytics.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/water_budget/update_water_budget_state_cubit.dart';
import '../domain/usecases/water_budget.dart';
import '../presentation/pump_tabs/budget_allocation.dart';
import '../presentation/pump_tabs/pump_details.dart';
import '../presentation/pump_tabs/pump_history.dart';
import '../presentation/pump_tabs/pump_users.dart';
import '../presentation/pump_tabs/water_budget.dart';

class PumpActionScreen extends StatefulWidget {
  final User userData;
  final int pumpStationId;
  final String pumpStationName;

  const PumpActionScreen({
    Key? key,
    required this.userData,
    required this.pumpStationId,
    required this.pumpStationName,
  }) : super(key: key);

  @override
  State<PumpActionScreen> createState() => _PumpActionScreenState();
}

class _PumpActionScreenState extends State<PumpActionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _brand = Color(0xFF3182CE);
  static const _textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UpdateWaterBudgetScreenCubit()
            ..loadWaterBudget(
              useCase: serviceLocator<GetWaterBudgetUseCase>(),
              params: widget.pumpStationId,
            ),
        ),
        BlocProvider(create: (_) => UpdateWaterBudgetButtonCubit()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: TabBarView(
          controller: _tabController,
          children: [
            BudgetTab(pumpStationId: widget.pumpStationId),
            AllocationsTab(pumpStationId: widget.pumpStationId),
            HistoryTab(pumpStationId: widget.pumpStationId),
            UsersTab(pumpStationId: widget.pumpStationId),
            PumpDetailsTab(
              pumpStationId: widget.pumpStationId,
              userRole: widget.userData.role,
            ),
            PumpAnalyticsTab(pumpStationId: widget.pumpStationId),
            UserElectricityHistoryTab(pumpStationId: widget.pumpStationId),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _brand,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pumpStationName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: _surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: _brand,
            unselectedLabelColor: _textSecondary,
            indicatorColor: _brand,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Budget'),
              Tab(icon: Icon(Icons.settings, size: 20), text: 'Allocation'),
              Tab(icon: Icon(Icons.history, size: 20), text: 'Usages History'),
              Tab(icon: Icon(Icons.people, size: 20), text: 'Pump Users'),
              Tab(icon: Icon(Icons.info, size: 20), text: 'Pump Info'),
              Tab(
                icon: Icon(Icons.analytics, size: 20),
                text: 'Pump Analytics',
              ),
              Tab(
                icon: Icon(Icons.analytics, size: 20),
                text: 'Electricity History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
