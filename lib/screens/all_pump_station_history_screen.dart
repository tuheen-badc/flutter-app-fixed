import 'package:demo_app/common/bloc/all_pump_station_history/pump_station_history_state_cubit.dart';
import 'package:demo_app/data/models/pump_station_history.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/all_pump_station_history/all_pump_station_history_state.dart';
import '../data/models/location.dart';
import '../data/models/pump_station_basic_list.dart';
import '../domain/repository/pump_station.dart';
import '../domain/usecases/all_pump_station_history.dart';
import '../presentation/drawer/drawer_config.dart';

class AllPumpStationHistoryScreen extends StatefulWidget {
  final User userData;

  const AllPumpStationHistoryScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<AllPumpStationHistoryScreen> createState() =>
      _AllPumpStationHistoryScreenState();
}

class _AllPumpStationHistoryScreenState
    extends State<AllPumpStationHistoryScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;
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

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _accent = Color(0xFF805AD5);
  static const _info = Color(0xFF3182CE);
  static const _warning = Color(0xFFF59E0B);
  static const _success = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    // Only load pump stations for USER role
    if (_isUser) {
      _loadPumpStations();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    return widget.userData.role.name == 'ADMIN' ||
        widget.userData.role.name == 'SUPER_ADMIN';
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

  void _loadHistory(BuildContext ctx) {
    ctx.read<AllPumpStationHistoryCubit>().loadPumpStationHistory(
      useCase: serviceLocator<AllPumpStationHistoryUseCase>(),
      params: PumpStationHistoryParam(
        page: currentPage,

        size: pageSize,
        userPhone: _isAdmin && _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        fromDate: fromDate,
        toDate: toDate,
        // Use pump station filter for USER role, location filter for others
        pumpStationId: _isUser ? selectedPumpStation?.id : null,
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
        DateTime? tempFromDate = fromDate;
        DateTime? tempToDate = toDate;
        String tempPhone = _phoneController.text;

        // For USER role
        PumpStationBasicDto? tempPumpStation = selectedPumpStation;

        // For non-USER roles
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
                'Filter History',
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
                      // User Phone Filter (Admin only)
                      if (_isAdmin) ...[
                        const Text(
                          'User Phone',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
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
                      ],

                      // Conditional Filter: Pump Station for USER, Location for others
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
                        const SizedBox(height: 20),
                      ] else ...[
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
                        const SizedBox(height: 20),
                      ],

                      // Date Range Filter
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
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
                                    primary: _brand,
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
                                    primary: _brand,
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
                _GhostButton(
                  label: 'Clear',
                  onPressed: () {
                    Navigator.of(builderContext).pop();
                    setState(() {
                      _phoneController.clear();
                      fromDate = null;
                      toDate = null;

                      if (_isUser) {
                        // Clear pump station filter
                        selectedPumpStation = pumpStations.isNotEmpty
                            ? pumpStations.first
                            : null;
                      } else {
                        // Clear location filter
                        filterDivision = null;
                        filterDistrict = null;
                        filterUpazilla = null;
                        filterUnion = null;
                      }

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
                      _phoneController.text = tempPhone;
                      fromDate = tempFromDate;
                      toDate = tempToDate;

                      if (_isUser) {
                        // Apply pump station filter
                        selectedPumpStation = tempPumpStation;
                      } else {
                        // Apply location filter
                        filterDivision = tempLocation.division;
                        filterDistrict = tempLocation.district;
                        filterUpazilla = tempLocation.upazilla;
                        filterUnion = tempLocation.union;
                      }

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

  String _getFilterSummary() {
    List<String> filters = [];

    if (_isAdmin && _phoneController.text.isNotEmpty) {
      filters.add('Phone: ${_phoneController.text}');
    }

    // Show pump station filter for USER role
    if (_isUser) {
      if (selectedPumpStation != null && selectedPumpStation!.id != null) {
        filters.add(selectedPumpStation!.name);
      }
    } else {
      // Show location filter for non-USER roles
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
      create: (_) => AllPumpStationHistoryCubit()
        ..loadPumpStationHistory(
          useCase: serviceLocator<AllPumpStationHistoryUseCase>(),
          params: PumpStationHistoryParam(page: currentPage, size: pageSize),
        ),
      child: Builder(
        builder: (providerContext) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: _bg,
            drawer: RoleBasedDrawer(
              userData: widget.userData,
              initialActiveItem: DrawerMenuItem.pumpUsagesHistory,
            ),
            appBar: CustomTopBar(
              title: 'Water Supply History',
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

                // History List
                Expanded(
                  child:
                      BlocBuilder<
                        AllPumpStationHistoryCubit,
                        AllPumpStationHistoryState
                      >(
                        builder: (context, state) {
                          if (state is AllPumpStationHistoryLoadingState) {
                            return const _CenteredLoader();
                          }

                          if (state is AllPumpStationHistoryErrorState) {
                            return _ErrorView(
                              message: state.errorMessage,
                              onRetry: () => _loadHistory(providerContext),
                            );
                          }

                          if (state is AllPumpStationHistoryLoadedState) {
                            if (state.historyList.isEmpty) {
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

                          // Initial state or unknown state
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

  Widget _buildHistoryCard(PumpStationHistoryItem item) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

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
                  // Pump Station Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(
                      Icons.water_damage,
                      color: _info,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Station Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.pumpStationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Station #${item.pumpStationId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _info,
                            ),
                          ),
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
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: _muted),
                        const SizedBox(width: 4),
                        Text(
                          item.durationFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User Info (Admin only)
              if (_isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _info.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: _info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.userName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            Text(
                              item.userPhone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Divider
              const Divider(color: _border, height: 1),

              const SizedBox(height: 16),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Volume',
                      value: '${item.volumeSupplied.toStringAsFixed(1)} L',
                      color: _info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.payments_outlined,
                      label: 'Cost',
                      value: currencyFormat.format(item.balanceDeducted),
                      color: _accent,
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
                    _TimeRow(
                      icon: Icons.play_circle_outline,
                      label: 'Started',
                      time: item.startedAt,
                    ),
                    const SizedBox(height: 8),
                    _TimeRow(
                      icon: Icons.stop_circle_outlined,
                      label: 'Ended',
                      time: item.endedAt,
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
                    color: _warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: _warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.endReason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textPrimary,
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
            backgroundColor: _AllPumpStationHistoryScreenState._brand,
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
            foregroundColor: _AllPumpStationHistoryScreenState._textSecondary,
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
          color: _AllPumpStationHistoryScreenState._brand,
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
              Icons.water_damage_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Water Supply History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AllPumpStationHistoryScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your water supply sessions will appear here',
              style: TextStyle(
                fontSize: 14,
                color: _AllPumpStationHistoryScreenState._textSecondary,
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
              'Error Loading History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AllPumpStationHistoryScreenState._textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _AllPumpStationHistoryScreenState._textSecondary,
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _AllPumpStationHistoryScreenState._textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime time;

  const _TimeRow({required this.icon, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _AllPumpStationHistoryScreenState._textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _AllPumpStationHistoryScreenState._textSecondary,
          ),
        ),
        Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(time.toLocal()),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _AllPumpStationHistoryScreenState._textPrimary,
          ),
        ),
      ],
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
        color: _AllPumpStationHistoryScreenState._surface,
        border: const Border(
          top: BorderSide(color: _AllPumpStationHistoryScreenState._border),
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
              color: _AllPumpStationHistoryScreenState._textPrimary,
            ),
          ),
          _BrandButton(label: 'Next', onPressed: onNext),
        ],
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
          border: Border.all(color: _AllPumpStationHistoryScreenState._border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: _AllPumpStationHistoryScreenState._brand,
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
                      color: _AllPumpStationHistoryScreenState._textSecondary,
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
                          ? _AllPumpStationHistoryScreenState._textPrimary
                          : _AllPumpStationHistoryScreenState._muted,
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
