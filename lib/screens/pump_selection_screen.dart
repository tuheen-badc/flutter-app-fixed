// pump_selection_screen.dart
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/screens/pump_tabs_container.dart';
import 'package:flutter/material.dart';

import '../presentation/drawer/drawer_config.dart';

class PumpSelectionScreen extends StatefulWidget {
  final User userData;

  const PumpSelectionScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<PumpSelectionScreen> createState() => _PumpSelectionScreenState();
}

class _PumpSelectionScreenState extends State<PumpSelectionScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Division? selectedDivision;
  District? selectedDistrict;
  Upazilla? selectedUpazilla;
  Union? selectedUnion;
  PumpStation? selectedPumpStation;

  // Incremented on clear to force LocationSelector re-mount
  int _selectorKey = 0;

  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);

  bool get _canProceed => selectedPumpStation != null;

  bool get _hasAnySelection =>
      selectedDivision != null ||
      selectedDistrict != null ||
      selectedUpazilla != null ||
      selectedUnion != null ||
      selectedPumpStation != null;

  void _clearSelection() {
    setState(() {
      selectedDivision = null;
      selectedDistrict = null;
      selectedUpazilla = null;
      selectedUnion = null;
      selectedPumpStation = null;
      _selectorKey++;
    });
  }

  void _proceed() {
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pump station to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PumpActionScreen(
          userData: widget.userData,
          pumpStationId: selectedPumpStation!.id,
          pumpStationName: selectedPumpStation!.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: _bg,
      drawer: RoleBasedDrawer(
        userData: widget.userData,
        initialActiveItem: DrawerMenuItem.analytics,
      ),
      appBar: CustomTopBar(
        title: 'Select Pump Station',
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _brand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: _brand,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Select Pump Station',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose division and district to load stations. '
                      'Upazilla and union are optional refinements.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    LocationSelector(
                      key: ValueKey(_selectorKey),
                      showPumpStation: true,
                      showDivision: true,
                      showDistrict: true,
                      showUpazilla: true,
                      showUnion: true,
                      initialSelection: LocationSelection(
                        division: selectedDivision,
                        district: selectedDistrict,
                        upazilla: selectedUpazilla,
                        union: selectedUnion,
                        pumpStation: selectedPumpStation,
                      ),
                      onSelectionChanged: (selection) {
                        setState(() {
                          selectedDivision = selection.division;
                          selectedDistrict = selection.district;
                          selectedUpazilla = selection.upazilla;
                          selectedUnion = selection.union;
                          selectedPumpStation = selection.pumpStation;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: _surface,
              border: const Border(top: BorderSide(color: _border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Clear — always enabled
                  _ClearButton(
                    hasSelection: _hasAnySelection,
                    onPressed: _clearSelection,
                  ),
                  const SizedBox(width: 12),
                  // Proceed
                  Expanded(
                    flex: 3,
                    child: _ProceedButton(
                      enabled: _canProceed,
                      onPressed: _proceed,
                    ),
                  ),
                ],
              ),
            ),
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

// ── Clear Button ──────────────────────────────────────────────────────────────

class _ClearButton extends StatelessWidget {
  final bool hasSelection;
  final VoidCallback onPressed;

  static const _brand = Color(0xFF3182CE);
  static const _border = Color(0xFFE2E8F0);
  static const _textSecondary = Color(0xFF718096);

  const _ClearButton({required this.hasSelection, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hasSelection
              ? const Color(0xFFEBF8FF)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? _brand.withOpacity(0.4) : _border,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: _brand.withOpacity(0.08),
            highlightColor: _brand.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      hasSelection ? Icons.restart_alt : Icons.clear_all,
                      key: ValueKey(hasSelection),
                      size: 18,
                      color: hasSelection ? _brand : _textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasSelection ? _brand : _textSecondary,
                      letterSpacing: 0.2,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Proceed Button ────────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  static const _brand = Color(0xFF3182CE);
  static const _brandDark = Color(0xFF2B6CB0);
  static const _muted = Color(0xFFA0AEC0);

  const _ProceedButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [_brand, _brandDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : const Color(0xFFEDF2F7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _brand.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: enabled ? Colors.white : _muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: enabled
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: enabled ? Colors.white : _muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
