// electricity_availability_screen.dart
import 'package:demo_app/data/models/electricity_status.dart';
import 'package:demo_app/data/models/electricity_status_criteria.dart';
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/domain/usecases/electricity_status.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/electricity_status/electricity_status_state.dart';
import '../common/bloc/electricity_status/electricity_status_state_cubit.dart';
import '../data/models/pump_station_basic_list.dart';
import '../domain/repository/pump_station.dart';
import '../presentation/drawer/drawer_config.dart';

class ElectricityAvailabilityScreen extends StatefulWidget {
  final User userData;

  const ElectricityAvailabilityScreen({Key? key, required this.userData})
    : super(key: key);

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

  // Pump station filter state (for USER role)
  List<PumpStationBasicDto> pumpStations = [];
  PumpStationBasicDto? selectedPumpStation;
  bool isLoadingPumpStations = false;

  // Location filter state (for non-USER roles)
  Division? filterDivision;
  District? filterDistrict;
  Upazilla? filterUpazilla;
  Union? filterUnion;
  int? filterPumpStationId;

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
  static const _warning = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    // Only load pump stations for USER role
    if (_isUser) {
      _loadPumpStations();
    }
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
    ctx.read<ElectricityAvailabilityCubit>().loadElectricityStatus(
      useCase: serviceLocator<ElectricityStatusUseCase>(),
      params: ElectricityStatusCriteria(
        page: currentPage,
        size: pageSize,
        // Use pump station filter for USER role, location filter for others
        pumpStationId: _isUser ? selectedPumpStation?.id : filterPumpStationId,
        divisionId: !_isUser ? filterDivision?.id : null,
        districtId: !_isUser ? filterDistrict?.id : null,
        upazillaId: !_isUser ? filterUpazilla?.id : null,
        unionId: !_isUser ? filterUnion?.id : null,
      ),
    );
  }

  void _showFilterDialog(BuildContext providerContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // For USER role
        PumpStationBasicDto? tempPumpStation = selectedPumpStation;

        // For non-USER roles
        LocationSelection tempLocation = LocationSelection(
          division: filterDivision,
          district: filterDistrict,
          upazilla: filterUpazilla,
          union: filterUnion,
        );
        String tempPumpStationId = filterPumpStationId?.toString() ?? '';

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
                      // Conditional Filter: Pump Station dropdown for USER, Location + ID for others
                      if (_isUser) ...[
                        // Pump Station Dropdown Filter (USER role only)
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
                            value: tempPumpStation,
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
                          ),
                        ),
                      ] else ...[
                        // Pump Station ID Filter (non-USER roles)
                        const Text(
                          'Pump Station ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: TextEditingController(
                            text: tempPumpStationId,
                          ),
                          onChanged: (value) => tempPumpStationId = value,
                          decoration: InputDecoration(
                            hintText: 'Enter pump station ID',
                            prefixIcon: const Icon(Icons.numbers, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        // Location Filter (non-USER roles)
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
                      if (_isUser) {
                        // Clear pump station filter
                        selectedPumpStation = pumpStations.isNotEmpty
                            ? pumpStations.first
                            : null;
                      } else {
                        // Clear location and pump station ID filters
                        filterDivision = null;
                        filterDistrict = null;
                        filterUpazilla = null;
                        filterUnion = null;
                        filterPumpStationId = null;
                      }
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
                      if (_isUser) {
                        // Apply pump station filter
                        selectedPumpStation = tempPumpStation;
                      } else {
                        // Apply location and pump station ID filters
                        filterDivision = tempLocation.division;
                        filterDistrict = tempLocation.district;
                        filterUpazilla = tempLocation.upazilla;
                        filterUnion = tempLocation.union;
                        filterPumpStationId = tempPumpStationId.isNotEmpty
                            ? int.tryParse(tempPumpStationId)
                            : null;
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

    // Show pump station filter for USER role
    if (_isUser) {
      if (selectedPumpStation != null && selectedPumpStation!.id != null) {
        filters.add(selectedPumpStation!.name);
      }
    } else {
      // Show pump station ID and location filter for non-USER roles
      if (filterPumpStationId != null) {
        filters.add('Station #$filterPumpStationId');
      }

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
    return BlocProvider(
      create: (_) => ElectricityAvailabilityCubit()
        ..loadElectricityStatus(
          useCase: serviceLocator<ElectricityStatusUseCase>(),
          params: ElectricityStatusCriteria(page: currentPage, size: pageSize),
        ),
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
                // Filter Section
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

                // Status List
                Expanded(
                  child:
                      BlocBuilder<
                        ElectricityAvailabilityCubit,
                        ElectricityAvailabilityState
                      >(
                        builder: (context, state) {
                          if (state is ElectricityAvailabilityLoadingState) {
                            return const _CenteredLoader();
                          }

                          if (state is ElectricityAvailabilityErrorState) {
                            return _ErrorView(
                              message: state.errorMessage,
                              onRetry: () => _loadStatus(providerContext),
                            );
                          }

                          if (state is ElectricityAvailabilityLoadedState) {
                            if (state.statusList.isEmpty) {
                              return const _EmptyView();
                            }

                            return Column(
                              children: [
                                // List Items
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: state.statusList.length,
                                    itemBuilder: (context, index) {
                                      final item = state.statusList[index];
                                      return _AnimatedIn(
                                        delay: Duration(
                                          milliseconds: 40 * (index + 1),
                                        ),
                                        child: _buildStatusCard(item),
                                      );
                                    },
                                  ),
                                ),

                                // Pagination Controls
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(ElectricityAvailabilityIndicator item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: _brand.withOpacity(0.06),
        highlightColor: Colors.transparent,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Station Icon
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

                  // Station Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: _textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

              // Phase Status
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

              const SizedBox(height: 12),

              // Last Updated
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: _textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Updated: ${_formatDateTime(item.lastUpdatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    }
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

// --- Reusable widgets ---
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
            backgroundColor: _ElectricityAvailabilityScreenState._brand,
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
            foregroundColor: _ElectricityAvailabilityScreenState._textSecondary,
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

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: _ElectricityAvailabilityScreenState._brand,
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
        padding: const EdgeInsets.all(24.0),
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
              'No Electricity Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ElectricityAvailabilityScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Electricity availability data will appear here',
              style: TextStyle(
                fontSize: 14,
                color: _ElectricityAvailabilityScreenState._textSecondary,
              ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ElectricityAvailabilityScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _ElectricityAvailabilityScreenState._textSecondary,
              ),
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
        color: _ElectricityAvailabilityScreenState._surface,
        border: const Border(
          top: BorderSide(color: _ElectricityAvailabilityScreenState._border),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BrandButton(label: 'Previous', onPressed: onPrev),
          Text(
            'Page $current of $total',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _ElectricityAvailabilityScreenState._textPrimary,
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
