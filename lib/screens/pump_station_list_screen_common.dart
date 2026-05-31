import 'package:demo_app/data/models/pump_execution_payload.dart';
import 'package:demo_app/data/models/pump_execution_request_type.dart';
import 'package:demo_app/domain/usecases/pump_station_execution_request.dart';
import 'package:demo_app/domain/usecases/pump_station_list.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../common/bloc/pump_list/pump_control_button_state.dart';
import '../common/bloc/pump_list/pump_control_button_state_cubit.dart';
import '../common/bloc/pump_list/pump_station_list_state.dart';
import '../common/bloc/pump_list/pump_station_list_state_cubit.dart';
import '../data/models/location.dart';
import '../data/models/pump_list_criteria.dart';
import '../data/models/pump_station_list.dart';
import 'location_selector.dart';

// ============================================================================
// FULL SCREEN VERSION (with Drawer) - Used when user logs in
// ============================================================================
class PumpStationControlContent extends StatefulWidget {
  final int userId;
  final String userRole;

  const PumpStationControlContent({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<PumpStationControlContent> createState() =>
      _PumpStationControlContentState();
}

class _PumpStationControlContentState extends State<PumpStationControlContent> {
  int currentPage = 0;
  final int pageSize = 20;

  // Location filter state - store full objects instead of just IDs
  Division? filterDivision;
  District? filterDistrict;
  Upazilla? filterUpazilla;
  Union? filterUnion;

  // Track local pending requests (for immediate UI feedback before backend confirms)
  Map<int, RequestInfo> localPendingRequests = {};

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
  static const _info = Color(0xFF3182CE);

  bool get _isUser {
    return widget.userRole == 'USER';
  }

  // Store the builder context that has access to providers
  BuildContext? _providerContext;

  void _loadStations() {
    if (_providerContext == null) return;

    final criteria = PumpStationCriteria(
      page: currentPage,
      size: pageSize,
      divisionId: filterDivision?.id,
      districtId: filterDistrict?.id,
      upazillaId: filterUpazilla?.id,
      unionId: filterUnion?.id,
      userId: widget.userId,
    );

    _providerContext!.read<PumpStationCubit>().loadPumpStations(
      useCase: serviceLocator<PumpStationListUseCase>(),
      params: criteria,
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;

    // Capture the correct context that has access to providers
    final scaffoldContext = _providerContext!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        LocationSelection tempSelection = LocationSelection(
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
                'Filter by Location',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(builderContext).size.width * 0.9,
                  child: LocationSelector(
                    initialSelection: tempSelection,
                    onSelectionChanged: (selection) {
                      setDialogState(() {
                        tempSelection = selection;
                      });
                    },
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
                      filterDivision = null;
                      filterDistrict = null;
                      filterUpazilla = null;
                      filterUnion = null;
                      currentPage = 0;
                    });
                    // Use the captured scaffold context
                    final criteria = PumpStationCriteria(
                      page: currentPage,
                      size: pageSize,
                      divisionId: filterDivision?.id,
                      districtId: filterDistrict?.id,
                      upazillaId: filterUpazilla?.id,
                      unionId: filterUnion?.id,
                      userId: widget.userId,
                    );
                    scaffoldContext.read<PumpStationCubit>().loadPumpStations(
                      useCase: serviceLocator<PumpStationListUseCase>(),
                      params: criteria,
                    );
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
                      filterDivision = tempSelection.division;
                      filterDistrict = tempSelection.district;
                      filterUpazilla = tempSelection.upazilla;
                      filterUnion = tempSelection.union;
                      currentPage = 0;
                    });
                    // Use the captured scaffold context
                    final criteria = PumpStationCriteria(
                      page: currentPage,
                      size: pageSize,
                      divisionId: filterDivision?.id,
                      districtId: filterDistrict?.id,
                      upazillaId: filterUpazilla?.id,
                      unionId: filterUnion?.id,
                      userId: widget.userId,
                    );
                    scaffoldContext.read<PumpStationCubit>().loadPumpStations(
                      useCase: serviceLocator<PumpStationListUseCase>(),
                      params: criteria,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
    _loadStations();
  }

  void _togglePump(BuildContext context, PumpStationItem station) {
    context.read<PumpControlButtonCubit>().togglePumpStation(
      useCase: serviceLocator<PumpStationExecutionUseCase>(),
      stationId: station.id,
      params: PumpExecutionPayload(
        pumpStationId: station.id,
        type: station.running
            ? PumpExecutionRequestType.STOP
            : PumpExecutionRequestType.START,
      ),
    );
  }

  String _getFilterSummary() {
    if (filterDivision == null &&
        filterDistrict == null &&
        filterUpazilla == null &&
        filterUnion == null) {
      return 'All Locations';
    }

    List<String> parts = [];
    if (filterUnion != null)
      parts.add(filterUnion!.name);
    else if (filterUpazilla != null)
      parts.add(filterUpazilla!.name);
    else if (filterDistrict != null)
      parts.add(filterDistrict!.name);
    else if (filterDivision != null)
      parts.add(filterDivision!.name);

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PumpStationCubit()
            ..loadPumpStations(
              useCase: serviceLocator<PumpStationListUseCase>(),
              params: PumpStationCriteria(
                page: currentPage,
                size: pageSize,
                userId: widget.userId,
              ),
            ),
        ),
        BlocProvider(create: (_) => PumpControlButtonCubit()),
      ],
      child: Builder(
        builder: (builderContext) {
          // Store the context that has access to providers
          _providerContext = builderContext;

          return MultiBlocListener(
            listeners: [
              BlocListener<PumpControlButtonCubit, PumpControlButtonState>(
                listener: (context, state) {
                  if (state is PumpControlButtonSuccessState) {
                    // Store local pending request for immediate UI feedback
                    setState(() {
                      localPendingRequests[state.stationId] = RequestInfo(
                        requestTime: state.requestTime,
                        isStartRequest: state.isRunning,
                      );
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.isRunning
                              ? 'Pump station start request submitted!'
                              : 'Pump station stop request submitted!',
                        ),
                        backgroundColor: _success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Reset the button state
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        context.read<PumpControlButtonCubit>().resetState();
                      }
                    });

                    // Reload stations to get backend confirmation (if available)
                    _loadStations();
                  } else if (state is PumpControlButtonFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: _danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    context.read<PumpControlButtonCubit>().resetState();
                  }
                },
              ),
            ],
            child: Column(
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
                        ),
                      ),
                      _BrandButton(
                        label: 'Filter',
                        onPressed: () => _showFilterDialog(),
                        dense: true,
                      ),
                    ],
                  ),
                ),

                // Stations List
                Expanded(
                  child: BlocBuilder<PumpStationCubit, PumpStationState>(
                    builder: (context, state) {
                      if (state is PumpStationLoadingState) {
                        return const _CenteredLoader();
                      }

                      if (state is PumpStationErrorState) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: () => _loadStations(),
                        );
                      }

                      if (state is PumpStationLoadedState) {
                        if (state.stationList.isEmpty) {
                          return const _EmptyView();
                        }

                        // Clear local pending requests when backend confirms
                        for (var station in state.stationList) {
                          // If backend has pending request, clear local state
                          if (station.pendingRequestType != null &&
                              localPendingRequests.containsKey(station.id)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  localPendingRequests.remove(station.id);
                                });
                              }
                            });
                          }
                          // If backend cleared pending and station state matches request
                          else if (station.pendingRequestType == null &&
                              localPendingRequests.containsKey(station.id)) {
                            final localRequest =
                                localPendingRequests[station.id]!;
                            if (station.running ==
                                localRequest.isStartRequest) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    localPendingRequests.remove(station.id);
                                  });
                                }
                              });
                            }
                          }
                        }

                        return Column(
                          children: [
                            // List Items
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: state.stationList.length,
                                itemBuilder: (context, index) {
                                  final station = state.stationList[index];
                                  return _AnimatedIn(
                                    delay: Duration(
                                      milliseconds: 40 * (index + 1),
                                    ),
                                    child: _buildStationCard(context, station),
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
                                    ? () => _goToPage(state.currentPage - 1)
                                    : null,
                                onNext: state.currentPage < state.totalPages - 1
                                    ? () => _goToPage(state.currentPage + 1)
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

  Widget _buildStationCard(BuildContext context, PumpStationItem station) {
    // Priority 1: Check backend persistent state
    final hasBackendPendingRequest = station.pendingRequestType != null;
    final backendRequestedAt = station.requestedAt;
    final backendPendingType = station.pendingRequestType;

    // Priority 2: Check local pending request (immediate feedback)
    final hasLocalPendingRequest = localPendingRequests.containsKey(station.id);
    final localRequestInfo = localPendingRequests[station.id];

    // Determine which pending state to show
    final hasPendingRequest =
        hasBackendPendingRequest || hasLocalPendingRequest;
    final displayRequestedAt = hasBackendPendingRequest
        ? backendRequestedAt
        : localRequestInfo?.requestTime;
    final displayPendingType = hasBackendPendingRequest
        ? backendPendingType
        : (localRequestInfo?.isStartRequest == true
              ? PumpExecutionRequestType.START
              : PumpExecutionRequestType.STOP);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
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
                    color: station.running
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: station.running
                          ? _success.withOpacity(0.3)
                          : _border,
                    ),
                  ),
                  child: Icon(
                    station.running ? Icons.water : Icons.water_damage,
                    color: station.running ? _success : _info,
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
                        station.name,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: station.running
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              station.running ? 'Running' : 'Stopped',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: station.running ? _success : _danger,
                              ),
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

            // Divider
            const Divider(color: _border, height: 1),

            const SizedBox(height: 16),

            // Location Info
            _LocationGrid(station: station),

            // Started At Time (when pump is actually running)
            if (station.running && station.startedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _success.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      size: 16,
                      color: _success,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Started at: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _success,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(station.startedAt!.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Pending Request Info (backend persistent + local immediate feedback)
            if (hasPendingRequest && displayRequestedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: _warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayPendingType == PumpExecutionRequestType.START
                                ? 'Start request placed'
                                : 'Stop request placed',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'MMM dd • hh:mm a',
                            ).format(displayRequestedAt.toLocal()),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Control Button
            _ControlButton(
              station: station,
              hasPendingRequest: hasPendingRequest,
              pendingRequestType: displayPendingType,
              isUser: _isUser,
              onPressed: () => _togglePump(context, station),
            ),
          ],
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

// ============================================================================
// REQUEST INFO MODEL
// ============================================================================
class RequestInfo {
  final DateTime requestTime;
  final bool isStartRequest;

  RequestInfo({required this.requestTime, required this.isStartRequest});
}

// ============================================================================
// REUSABLE WIDGETS - All helper widgets below
// ============================================================================

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
            backgroundColor: const Color(0xFF3182CE),
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
            foregroundColor: const Color(0xFF718096),
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

class _LocationGrid extends StatelessWidget {
  final PumpStationItem station;

  const _LocationGrid({required this.station});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LocationTile(
                icon: Icons.location_city,
                label: 'Division',
                value: station.divisionName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LocationTile(
                icon: Icons.map_outlined,
                label: 'District',
                value: station.districtName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LocationTile(
                icon: Icons.place_outlined,
                label: 'Upazilla',
                value: station.upazillaName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LocationTile(
                icon: Icons.location_on_outlined,
                label: 'Union',
                value: station.unionName,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LocationTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF718096)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final PumpStationItem station;
  final bool hasPendingRequest;
  final PumpExecutionRequestType? pendingRequestType;
  final bool isUser;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.station,
    required this.hasPendingRequest,
    required this.pendingRequestType,
    required this.isUser,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpControlButtonCubit, PumpControlButtonState>(
      builder: (context, buttonState) {
        final isLoading =
            buttonState is PumpControlButtonLoadingState &&
            buttonState.stationId == station.id;

        // For non-USER roles: Hide button completely when pump is stopped (can't start)
        if (!isUser && !station.running && !hasPendingRequest) {
          return const SizedBox.shrink(); // Completely hide the button
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isLoading || hasPendingRequest) ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: station.running
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFA0AEC0),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : hasPendingRequest
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        pendingRequestType == PumpExecutionRequestType.START
                            ? 'Start Request Pending'
                            : 'Stop Request Pending',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        station.running ? Icons.stop : Icons.play_arrow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        station.running
                            ? 'Request Stop Pump'
                            : 'Request Start Pump',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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
          color: Color(0xFF3182CE),
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
              'No Pump Stations Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pump stations available in this area',
              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
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
              'Error Loading Stations',
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
        color: const Color(0xFFFFFFFF),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
              color: Color(0xFF2D3748),
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
