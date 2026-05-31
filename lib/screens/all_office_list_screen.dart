// all_office_list_screen.dart
import 'package:demo_app/data/models/office_response.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/office_overview_screen.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/all_office_list/all_office_list_state.dart';
import '../common/bloc/all_office_list/all_office_list_state_cubit.dart';
import '../data/models/location.dart';
import '../data/models/office_fetch_criteria.dart';
import '../domain/usecases/all_office_list.dart';
import 'location_selector.dart';

class AllOfficeListScreen extends StatefulWidget {
  final User userData;

  const AllOfficeListScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<AllOfficeListScreen> createState() => _AllOfficeListScreenState();
}

class _AllOfficeListScreenState extends State<AllOfficeListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPage = 0;
  final int pageSize = 20;

  // Location filter state
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
  static const _danger = Color(0xFFEF4444);

  // Store the builder context that has access to providers
  BuildContext? _providerContext;

  void _loadOffices() {
    if (_providerContext == null) return;

    final criteria = OfficeCriteria(
      page: currentPage,
      size: pageSize,
      divisionId: filterDivision?.id,
      districtId: filterDistrict?.id,
      upazillaId: filterUpazilla?.id,
      unionId: filterUnion?.id,
    );

    _providerContext!.read<AllOfficeCubit>().loadOffices(
      useCase: serviceLocator<AllOfficeListUseCase>(),
      params: criteria,
    );
  }

  void _showFilterDialog() {
    if (_providerContext == null) return;

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
                    final criteria = OfficeCriteria(page: 0, size: pageSize);
                    scaffoldContext.read<AllOfficeCubit>().loadOffices(
                      useCase: serviceLocator<AllOfficeListUseCase>(),
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
                    final criteria = OfficeCriteria(
                      page: 0,
                      size: pageSize,
                      divisionId: tempSelection.division?.id,
                      districtId: tempSelection.district?.id,
                      upazillaId: tempSelection.upazilla?.id,
                      unionId: tempSelection.union?.id,
                    );
                    scaffoldContext.read<AllOfficeCubit>().loadOffices(
                      useCase: serviceLocator<AllOfficeListUseCase>(),
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
    _loadOffices();
  }

  String _getFilterSummary() {
    if (filterDivision == null &&
        filterDistrict == null &&
        filterUpazilla == null &&
        filterUnion == null) {
      return 'All Locations';
    }

    if (filterUnion != null) return filterUnion!.name;
    if (filterUpazilla != null) return filterUpazilla!.name;
    if (filterDistrict != null) return filterDistrict!.name;
    if (filterDivision != null) return filterDivision!.name;

    return 'All Locations';
  }

  void _navigateToOfficeOverview(OfficeItem office) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfficeOverviewScreen(
          officeId: office.id,
          officeName: office.name,
          user: widget.userData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllOfficeCubit()
        ..loadOffices(
          useCase: serviceLocator<AllOfficeListUseCase>(),
          params: OfficeCriteria(page: currentPage, size: pageSize),
        ),
      child: Builder(
        builder: (builderContext) {
          _providerContext = builderContext;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: _bg,
            drawer: RoleBasedDrawer(userData: widget.userData),
            appBar: CustomTopBar(
              title: 'Offices',
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

                // Office List
                Expanded(
                  child: BlocBuilder<AllOfficeCubit, AllOfficeState>(
                    builder: (context, state) {
                      if (state is AllOfficeLoadingState) {
                        return const _CenteredLoader();
                      }

                      if (state is AllOfficeErrorState) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: _loadOffices,
                        );
                      }

                      if (state is AllOfficeLoadedState) {
                        if (state.officeList.isEmpty) {
                          return const _EmptyView();
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async => _loadOffices(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: state.officeList.length,
                                  itemBuilder: (context, index) {
                                    final office = state.officeList[index];
                                    return _AnimatedIn(
                                      delay: Duration(
                                        milliseconds: 40 * (index + 1),
                                      ),
                                      child: _buildOfficeCard(office),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Pagination
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

  Widget _buildOfficeCard(OfficeItem office) {
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
                // Office Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.business, color: _brand, size: 22),
                ),
                const SizedBox(width: 16),

                // Office Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        office.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 16),

            // Location Grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.location_city,
                        label: 'Division',
                        value: office.divisionName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.map_outlined,
                        label: 'District',
                        value: office.districtName,
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
                        value: office.upazillaName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LocationTile(
                        icon: Icons.location_on_outlined,
                        label: 'Union',
                        value: office.unionName,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Manage Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToOfficeOverview(office),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Manage Office',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
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

// ── Reusable widgets ────────────────────────────────────────────────────────

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
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Offices Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No offices available in this area',
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
              'Error Loading Offices',
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
