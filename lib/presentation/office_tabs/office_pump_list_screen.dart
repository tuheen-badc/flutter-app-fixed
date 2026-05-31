// screens/office_pumps_screen.dart
import 'package:demo_app/data/models/office_pump_criteria.dart';
import 'package:demo_app/data/models/office_pump_response.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/office_pump_list/office_pump_list_state.dart';
import '../../common/bloc/office_pump_list/office_pump_list_state_cubit.dart';
import '../../data/models/location.dart';
import '../../data/models/user_info.dart';
import '../../domain/usecases/office_pump_list.dart';
import '../../screens/location_selector.dart';
import '../../screens/pump_tabs_container.dart';

class OfficePumpsScreen extends StatefulWidget {
  final int officeId;
  final String officeName;
  final User user;

  const OfficePumpsScreen({
    Key? key,
    required this.officeId,
    required this.officeName,
    required this.user,
  }) : super(key: key);

  @override
  State<OfficePumpsScreen> createState() => _OfficePumpsScreenState();
}

class _OfficePumpsScreenState extends State<OfficePumpsScreen> {
  int currentPage = 0;
  final int pageSize = 20;

  // Location filter state
  Division? filterDivision;
  District? filterDistrict;
  Upazilla? filterUpazilla;
  Union? filterUnion;

  //total user
  //total pump
  //total running pump
  //total admin
  //total income - office
  //total operating hour

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);

  BuildContext? _providerContext;

  OfficePumpCriteria _buildCriteria({int? page}) => OfficePumpCriteria(
    officeId: widget.officeId,
    page: page ?? currentPage,
    size: pageSize,
    divisionId: filterDivision?.id,
    districtId: filterDistrict?.id,
    upazillaId: filterUpazilla?.id,
    unionId: filterUnion?.id,
  );

  void _loadPumps() {
    if (_providerContext == null) return;
    _providerContext!.read<OfficePumpListCubit>().loadOfficePumps(
      useCase: serviceLocator<OfficePumpListUseCase>(),
      params: _buildCriteria(),
    );
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
    _loadPumps();
  }

  String _getFilterSummary() {
    if (filterUnion != null) return filterUnion!.name;
    if (filterUpazilla != null) return filterUpazilla!.name;
    if (filterDistrict != null) return filterDistrict!.name;
    if (filterDivision != null) return filterDivision!.name;
    return 'All Locations';
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;
    final providerContext = _providerContext!;

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                      setDialogState(() => tempSelection = selection);
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
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      filterDivision = null;
                      filterDistrict = null;
                      filterUpazilla = null;
                      filterUnion = null;
                      currentPage = 0;
                    });
                    providerContext.read<OfficePumpListCubit>().loadOfficePumps(
                      useCase: serviceLocator<OfficePumpListUseCase>(),
                      params: OfficePumpCriteria(
                        officeId: widget.officeId,
                        page: 0,
                        size: pageSize,
                      ),
                    );
                  },
                ),
                _GhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                _BrandButton(
                  label: 'Apply',
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      filterDivision = tempSelection.division;
                      filterDistrict = tempSelection.district;
                      filterUpazilla = tempSelection.upazilla;
                      filterUnion = tempSelection.union;
                      currentPage = 0;
                    });
                    providerContext.read<OfficePumpListCubit>().loadOfficePumps(
                      useCase: serviceLocator<OfficePumpListUseCase>(),
                      params: OfficePumpCriteria(
                        officeId: widget.officeId,
                        page: 0,
                        size: pageSize,
                        divisionId: tempSelection.division?.id,
                        districtId: tempSelection.district?.id,
                        upazillaId: tempSelection.upazilla?.id,
                        unionId: tempSelection.union?.id,
                      ),
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

  void _navigateToPumpDetail(BuildContext context, OfficePumpItem pump) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PumpActionScreen(
          userData: widget.user,
          pumpStationId: pump.id,
          pumpStationName: pump.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfficePumpListCubit()
        ..loadOfficePumps(
          useCase: serviceLocator<OfficePumpListUseCase>(),
          params: OfficePumpCriteria(
            officeId: widget.officeId,
            page: 0,
            size: pageSize,
          ),
        ),
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pump Stations',
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
                        ),
                      ),
                      _BrandButton(
                        label: 'Filter',
                        onPressed: _showFilterDialog,
                        dense: true,
                      ),
                    ],
                  ),
                ),

                // Pump List
                Expanded(
                  child: BlocBuilder<OfficePumpListCubit, OfficePumpListState>(
                    builder: (context, state) {
                      if (state is OfficePumpListLoadingState) {
                        return const _CenteredLoader();
                      }

                      if (state is OfficePumpListErrorState) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: _loadPumps,
                        );
                      }

                      if (state is OfficePumpListLoadedState) {
                        if (state.pumpList.isEmpty) {
                          return const _EmptyView();
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async => _loadPumps(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: state.pumpList.length,
                                  itemBuilder: (ctx, i) {
                                    final pump = state.pumpList[i];
                                    return _AnimatedIn(
                                      delay: Duration(
                                        milliseconds: 40 * (i + 1),
                                      ),
                                      child: _buildPumpCard(ctx, pump),
                                    );
                                  },
                                ),
                              ),
                            ),
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

  Widget _buildPumpCard(BuildContext context, OfficePumpItem pump) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToPumpDetail(context, pump),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF8FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _brand.withOpacity(0.2)),
                ),
                child: const Icon(Icons.water_damage, color: _brand, size: 22),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pump.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: _muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pump.locationSummary,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: _muted),
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

// ── Reusable widgets ─────────────────────────────────────────────────────────

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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
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
            'No pump stations match the current filters',
            style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
          ),
        ],
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
            'Error Loading Pumps',
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
