// electricity_availability_screen.dart
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/electricity_history.dart';
import 'package:demo_app/data/models/electricity_history_criteria.dart';
import 'package:demo_app/domain/usecases/electricity_history.dart';
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/all_pump_list/all_pump_station_list_state.dart';
import '../common/bloc/all_pump_list/all_pump_station_list_state_cubit.dart';
import '../data/models/pump_list_criteria.dart';
import '../data/models/pump_station_list.dart';
import '../domain/usecases/all_pump_station_list.dart';
import '../domain/usecases/pump_station_list.dart';
import '../data/models/pump_station_basic_list.dart';
import '../domain/repository/pump_station.dart';
import '../presentation/drawer/drawer_config.dart';

class ElectricityAvailabilityScreen extends StatefulWidget {
  final User userData;

  const ElectricityAvailabilityScreen({super.key, required this.userData});

  @override
  State<ElectricityAvailabilityScreen> createState() =>
      _ElectricityAvailabilityScreenState();
}

class _ElectricityAvailabilityScreenState
    extends State<ElectricityAvailabilityScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentPage = 0;
  final int pageSize = 20;

  // Pump station filter state
  List<PumpStationBasicDto> pumpStations = [];
  PumpStationBasicDto? selectedPumpStation;
  bool isLoadingPumpStations = false;

  // Location filter state (for non-USER roles)
  Division? filterDivision;
  District? filterDistrict;
  Upazilla? filterUpazilla;
  Union? filterUnion;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);

  @override
  void initState() {
    super.initState();
    _loadPumpStations();
  }

  bool get _isUser {
    return widget.userData.role.name == 'USER';
  }

  Future<void> _loadPumpStations() async {
    setState(() => isLoadingPumpStations = true);

    try {
      final result = await serviceLocator<PumpStationRepository>()
          .pumpStationBasicList();

      result.fold(
        (error) {
          setState(() => isLoadingPumpStations = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load pump stations: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (stations) {
          final List<PumpStationBasicDto> stationList = stations;
          setState(() {
            // Add "All" option at the beginning
            pumpStations = [
              PumpStationBasicDto(id: null, name: 'All Pump Stations'),
              ...stationList,
            ];
            selectedPumpStation = pumpStations.first; // Default to "All"
            isLoadingPumpStations = false;
          });
        },
      );
    } catch (e) {
      setState(() => isLoadingPumpStations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load pump stations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadStatus(BuildContext ctx) {
    final int? targetStationId = selectedPumpStation?.id;

    // Determine the correct use case for fetching pump stations based on role
    final UseCase pumpUseCase = _isUser 
        ? serviceLocator<PumpStationListUseCase>() 
        : serviceLocator<AllPumpStationListUseCase>();

    ctx.read<AllPumpStationCubit>().loadPumpStations(
      useCase: pumpUseCase,
      params: PumpStationCriteria(
        page: currentPage,
        size: pageSize,
        userId: _isUser ? widget.userData.id : null,
        pumpStationId: targetStationId,
        divisionId: filterDivision?.id,
        districtId: filterDistrict?.id,
        upazillaId: filterUpazilla?.id,
        unionId: filterUnion?.id,
      ),
    );
  }

  void _showFilterDialog(BuildContext providerContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        PumpStationBasicDto? tempPumpStation = selectedPumpStation;
        LocationSelection tempLocation = LocationSelection(
          division: filterDivision,
          district: filterDistrict,
          upazilla: filterUpazilla,
          union: filterUnion,
        );

        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter Electricity Status',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pump Station',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: DropdownButtonFormField<PumpStationBasicDto>(
                          items: pumpStations.map((station) {
                            return DropdownMenuItem<PumpStationBasicDto>(
                              value: station,
                              child: Text(
                                station.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: station.id == null
                                      ? _textSecondary
                                      : _textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: isLoadingPumpStations
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    tempPumpStation = value;
                                  });
                                },
                          initialValue: tempPumpStation,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.water_damage,
                              size: 20,
                              color: _brand,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!_isUser) ...[
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LocationSelector(
                          initialSelection: tempLocation,
                          onSelectionChanged: (selection) {
                            setDialogState(() {
                              tempLocation = selection;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
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
                      selectedPumpStation = pumpStations.isNotEmpty
                          ? pumpStations.first
                          : null;
                      filterDivision = null;
                      filterDistrict = null;
                      filterUpazilla = null;
                      filterUnion = null;
                      currentPage = 0;
                    });
                    _loadStatus(providerContext);
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
                      selectedPumpStation = tempPumpStation;
                      if (!_isUser) {
                        filterDivision = tempLocation.division;
                        filterDistrict = tempLocation.district;
                        filterUpazilla = tempLocation.upazilla;
                        filterUnion = tempLocation.union;
                      }
                      currentPage = 0;
                    });
                    _loadStatus(providerContext);
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
    _loadStatus(ctx);
  }

  String _getFilterSummary() {
    List<String> filters = [];
    if (selectedPumpStation != null && selectedPumpStation!.id != null) {
      filters.add(selectedPumpStation!.name);
    }
    if (!_isUser) {
      if (filterUnion != null) {
        filters.add(filterUnion!.name);
      } else if (filterUpazilla != null) {
        filters.add(filterUpazilla!.name);
      } else if (filterDistrict != null) {
        filters.add(filterDistrict!.name);
      } else if (filterDivision != null) {
        filters.add(filterDivision!.name);
      }
    }
    return filters.isEmpty ? 'All Pump Stations' : filters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final int? targetStationId = selectedPumpStation?.id;
    
    // Determine the correct use case for fetching pump stations based on role
    final UseCase pumpUseCase = _isUser 
        ? serviceLocator<PumpStationListUseCase>() 
        : serviceLocator<AllPumpStationListUseCase>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = AllPumpStationCubit();
            cubit.loadPumpStations(
              useCase: pumpUseCase,
              params: PumpStationCriteria(
                page: currentPage,
                size: targetStationId != null ? 10 : pageSize,
                userId: _isUser ? widget.userData.id : null,
                pumpStationId: targetStationId,
                divisionId: filterDivision?.id,
                districtId: filterDistrict?.id,
                upazillaId: filterUpazilla?.id,
                unionId: filterUnion?.id,
              ),
            );
            return cubit;
          },
        ),
      ],
      child: Builder(
        builder: (providerContext) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: _bg,
            drawer: RoleBasedDrawer(
              userData: widget.userData,
              initialActiveItem: DrawerMenuItem.electricityStatus,
            ),
            appBar: CustomTopBar(
              title: 'Electricity Availability',
              onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: _cardDecoration,
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: _textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getFilterSummary(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: _textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _BrandButton(
                        label: 'Filter',
                        onPressed: () => _showFilterDialog(providerContext),
                        dense: true,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<AllPumpStationCubit, AllPumpStationState>(
                    builder: (context, pumpState) {
                      if (pumpState is AllPumpStationLoadingState) {
                        return const _CenteredLoader();
                      }

                      if (pumpState is AllPumpStationErrorState) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(pumpState.errorMessage, textAlign: TextAlign.center),
                                const SizedBox(height: 24),
                                _BrandButton(
                                  label: 'Retry',
                                  onPressed: () => _loadStatus(providerContext),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (pumpState is AllPumpStationLoadedState) {
                        // Locally enforce the pump station filter if one is selected
                        final displayList = targetStationId != null
                            ? pumpState.stationList.where((s) => s.id == targetStationId).toList()
                            : pumpState.stationList;

                        if (displayList.isEmpty) return const _EmptyView();

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  final station = displayList[index];
                                  return _AnimatedIn(
                                    delay: Duration(milliseconds: 40 * (index + 1)),
                                    child: _StationStatusCard(station: station),
                                  );
                                },
                              ),
                            ),

                            if (pumpState.totalPages > 1)
                              _PaginationBar(
                                current: pumpState.currentPage + 1,
                                total: pumpState.totalPages,
                                onPrev: pumpState.currentPage > 0
                                    ? () => _goToPage(pumpState.currentPage - 1, providerContext)
                                    : null,
                                onNext: pumpState.currentPage < pumpState.totalPages - 1
                                    ? () => _goToPage(pumpState.currentPage + 1, providerContext)
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
            ),
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
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// =============================================================================
// STATION STATUS CARD (FETHES ITS OWN LATEST STATUS FROM HISTORY)
// =============================================================================

class _StationStatusCard extends StatefulWidget {
  final PumpStationItem station;

  const _StationStatusCard({required this.station});

  @override
  State<_StationStatusCard> createState() => _StationStatusCardState();
}

class _StationStatusCardState extends State<_StationStatusCard> {
  bool isLoading = true;
  ElectricityStatusHistoryItem? latestStatus;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final result = await serviceLocator<ElectricityHistoryUseCase>().call(
      param: ElectricityHistoryCriteria(
        pumpStationId: widget.station.id,
        page: 0,
        size: 1,
      ),
    );

    if (mounted) {
      result.fold(
        (failure) => setState(() {
          error = failure.message;
          isLoading = false;
        }),
        (response) {
          final history = response as ElectricityStatusHistoryResponse;
          setState(() {
            latestStatus = history.historyList.isNotEmpty ? history.historyList.first : null;
            isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.electrical_services, color: Color(0xFF3182CE), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.station.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.station.unionName}, ${widget.station.upazillaName}, ${widget.station.districtName}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: latestStatus != null
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      latestStatus != null ? 'Active' : 'No Data',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: latestStatus != null 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: isLoading
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : latestStatus == null
                      ? const Center(child: Text('No status reported recently', style: TextStyle(fontSize: 12, color: Color(0xFF718096))))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPhaseItem('Phase 1', latestStatus!.phaseOneAvailable),
                            _buildPhaseItem('Phase 2', latestStatus!.phaseTwoAvailable),
                            _buildPhaseItem('Phase 3', latestStatus!.phaseThreeAvailable),
                          ],
                        ),
            ),
            if (!isLoading && latestStatus != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Color(0xFF718096)),
                  const SizedBox(width: 6),
                  Text(
                    'Updated: ${_formatTime(latestStatus!.loggedAt)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseItem(String label, bool isAvailable) {
    final success = const Color(0xFF10B981);
    final danger = const Color(0xFFEF4444);
    
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAvailable ? success : danger,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: TextStyle(fontSize: 9, color: isAvailable ? success : danger, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return DateFormat('MMM dd, HH:mm').format(dateTime);
  }
}

class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dense;

  const _BrandButton({required this.label, this.onPressed, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3182CE),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: dense ? 16 : 20, vertical: dense ? 10 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF718096),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF3182CE), strokeWidth: 3));
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.electrical_services_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No Electricity Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Electricity availability data will appear here', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const _PaginationBar({required this.current, required this.total, this.onPrev, this.onNext});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BrandButton(label: 'Previous', onPressed: onPrev),
          Text('Page $current of $total', style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _AnimatedInState extends State<_AnimatedIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<double> _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero).animate(_fade);
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
  }
}
