// location_selector.dart
import 'package:flutter/material.dart';

import '../data/models/location.dart';
import '../data/source/location_service.dart';

class LocationSelector extends StatefulWidget {
  final LocationSelection? initialSelection;
  final Function(LocationSelection)? onSelectionChanged;
  final bool showDivision;
  final bool showDistrict;
  final bool showUpazilla;
  final bool showUnion;
  final bool showPumpStation;
  final bool enableValidation;
  final AutovalidateMode? autovalidateMode;
  final LocationApiService? service;

  const LocationSelector({
    Key? key,
    this.initialSelection,
    this.onSelectionChanged,
    this.showDivision = true,
    this.showDistrict = true,
    this.showUpazilla = true,
    this.showUnion = true,
    this.showPumpStation = false,
    this.enableValidation = false,
    this.autovalidateMode,
    this.service,
  }) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class LocationSelectorController {
  _LocationSelectorState? _state;

  void _attach(_LocationSelectorState state) => _state = state;

  void _detach() => _state = null;

  bool validate() => _state?.validate() ?? false;

  void reset() => _state?.reset();

  LocationSelection? get selection => _state?.getCurrentSelection();
}

class _LocationSelectorState extends State<LocationSelector> {
  late final LocationApiService _service;
  final _formKey = GlobalKey<FormState>();

  List<Division> _divisions = [];
  List<District> _districts = [];
  List<Upazilla> _upazillas = [];
  List<Union> _unions = [];
  List<PumpStation> _pumpStations = [];
  List<PumpStation> _filteredPumpStations = []; // client-side search

  Division? _selectedDivision;
  District? _selectedDistrict;
  Upazilla? _selectedUpazilla;
  Union? _selectedUnion;
  PumpStation? _selectedPumpStation;

  bool _loadingDivisions = false;
  bool _loadingDistricts = false;
  bool _loadingUpazillas = false;
  bool _loadingUnions = false;
  bool _loadingPumpStations = false;

  int? _initialDivisionId;
  int? _initialDistrictId;
  int? _initialUpazillaId;
  int? _initialUnionId;
  int? _initialPumpStationId;

  final TextEditingController _pumpSearchController = TextEditingController();

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);

  /// Pump stations load as soon as division + district are both selected.
  bool get _canLoadPumpStations =>
      _selectedDivision != null && _selectedDistrict != null;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? LocationApiServiceImplementation();

    if (widget.initialSelection != null) {
      _initialDivisionId = widget.initialSelection!.division?.id;
      _initialDistrictId = widget.initialSelection!.district?.id;
      _initialUpazillaId = widget.initialSelection!.upazilla?.id;
      _initialUnionId = widget.initialSelection!.union?.id;
      _initialPumpStationId = widget.initialSelection!.pumpStation?.id;
    }

    _loadDivisions();
  }

  @override
  void dispose() {
    _pumpSearchController.dispose();
    super.dispose();
  }

  bool validate() {
    if (!widget.enableValidation) return true;
    return _formKey.currentState?.validate() ?? false;
  }

  void reset() {
    setState(() {
      _selectedDivision = null;
      _selectedDistrict = null;
      _selectedUpazilla = null;
      _selectedUnion = null;
      _selectedPumpStation = null;
      _districts = [];
      _upazillas = [];
      _unions = [];
      _pumpStations = [];
      _filteredPumpStations = [];
    });
    _formKey.currentState?.reset();
  }

  LocationSelection getCurrentSelection() => LocationSelection(
    division: _selectedDivision,
    district: _selectedDistrict,
    upazilla: _selectedUpazilla,
    union: _selectedUnion,
    pumpStation: _selectedPumpStation,
  );

  // ── Data loaders ─────────────────────────────────────────────────────────────

  Future<void> _loadDivisions() async {
    setState(() => _loadingDivisions = true);
    try {
      final divisions = await _service.fetchDivisions();
      setState(() {
        _divisions = divisions;
        _loadingDivisions = false;
        if (_initialDivisionId != null) {
          try {
            _selectedDivision = _divisions.firstWhere(
              (d) => d.id == _initialDivisionId,
            );
            _loadDistricts(_selectedDivision!.id, isInitial: true);
          } catch (_) {}
        }
      });
    } catch (_) {
      setState(() => _loadingDivisions = false);
      _showError('Failed to load divisions');
    }
  }

  Future<void> _loadDistricts(int divisionId, {bool isInitial = false}) async {
    setState(() {
      _loadingDistricts = true;
      if (!isInitial) {
        _districts = [];
        _selectedDistrict = null;
        _upazillas = [];
        _selectedUpazilla = null;
        _unions = [];
        _selectedUnion = null;
        _clearPumpStations();
      }
    });
    try {
      final districts = await _service.fetchDistricts(divisionId);
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
        if (isInitial && _initialDistrictId != null) {
          try {
            _selectedDistrict = _districts.firstWhere(
              (d) => d.id == _initialDistrictId,
            );
            _loadUpazillas(_selectedDistrict!.id, isInitial: true);
            // Minimum requirement met — load pump stations on init
            if (widget.showPumpStation) _loadPumpStations(isInitial: true);
          } catch (_) {}
        }
      });
      if (!isInitial) _notifySelectionChanged();
    } catch (_) {
      setState(() => _loadingDistricts = false);
      _showError('Failed to load districts');
    }
  }

  Future<void> _loadUpazillas(int districtId, {bool isInitial = false}) async {
    setState(() {
      _loadingUpazillas = true;
      if (!isInitial) {
        _upazillas = [];
        _selectedUpazilla = null;
        _unions = [];
        _selectedUnion = null;
      }
    });
    try {
      final upazillas = await _service.fetchUpazillas(districtId);
      setState(() {
        _upazillas = upazillas;
        _loadingUpazillas = false;
        if (isInitial && _initialUpazillaId != null) {
          try {
            _selectedUpazilla = _upazillas.firstWhere(
              (u) => u.id == _initialUpazillaId,
            );
            _loadUnions(_selectedUpazilla!.id, isInitial: true);
          } catch (_) {}
        }
      });
      if (!isInitial) _notifySelectionChanged();
    } catch (_) {
      setState(() => _loadingUpazillas = false);
      _showError('Failed to load upazillas');
    }
  }

  Future<void> _loadUnions(int upazillaId, {bool isInitial = false}) async {
    setState(() {
      _loadingUnions = true;
      if (!isInitial) {
        _unions = [];
        _selectedUnion = null;
      }
    });
    try {
      final unions = await _service.fetchUnions(upazillaId);
      setState(() {
        _unions = unions;
        _loadingUnions = false;
        if (isInitial && _initialUnionId != null) {
          try {
            _selectedUnion = _unions.firstWhere((u) => u.id == _initialUnionId);
          } catch (_) {}
        }
      });
      if (!isInitial) _notifySelectionChanged();
    } catch (_) {
      setState(() => _loadingUnions = false);
      _showError('Failed to load unions');
    }
  }

  /// Loads pump stations when division + district are selected (minimum).
  /// Upazilla and union are optional refinement filters.
  Future<void> _loadPumpStations({bool isInitial = false}) async {
    if (!widget.showPumpStation || !_canLoadPumpStations) return;

    setState(() {
      _loadingPumpStations = true;
      if (!isInitial) _clearPumpStations();
    });

    try {
      final pumpStations = await _service.fetchPumpStations(
        divisionId: _selectedDivision!.id,
        districtId: _selectedDistrict!.id,
        upazillaId: _selectedUpazilla?.id,
        unionId: _selectedUnion?.id,
      );

      setState(() {
        _pumpStations = pumpStations;
        _filteredPumpStations = pumpStations;
        _loadingPumpStations = false;
        // Keep selected pump station if still in the new list
        if (_selectedPumpStation != null) {
          try {
            _selectedPumpStation = _pumpStations.firstWhere(
              (ps) => ps.id == _selectedPumpStation!.id,
            );
          } catch (_) {
            _selectedPumpStation = null;
          }
        }
        if (isInitial && _initialPumpStationId != null) {
          try {
            _selectedPumpStation = _pumpStations.firstWhere(
              (ps) => ps.id == _initialPumpStationId,
            );
          } catch (_) {}
        }
      });

      if (!isInitial) _notifySelectionChanged();
    } catch (_) {
      setState(() => _loadingPumpStations = false);
      _showError('Failed to load pump stations');
    }
  }

  void _clearPumpStations() {
    _pumpStations = [];
    _filteredPumpStations = [];
    _selectedPumpStation = null;
  }

  // ── Pump search ───────────────────────────────────────────────────────────────

  void _filterPumpStations(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredPumpStations = q.isEmpty
          ? _pumpStations
          : _pumpStations.where((ps) {
              return ps.name.toLowerCase().contains(q) ||
                  ps.id.toString().contains(q);
            }).toList();
    });
  }

  // ── Pump search dialog ────────────────────────────────────────────────────────

  void _openPumpSearchDialog() {
    if (!_canLoadPumpStations || _pumpStations.isEmpty) return;

    _pumpSearchController.clear();
    _filterPumpStations('');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Dialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 48,
              ),
              child: SizedBox(
                height: MediaQuery.of(builderContext).size.height * 0.65,
                child: Column(
                  children: [
                    // ── Pinned Header ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.water_damage,
                            color: _brand,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Select Pump Station',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: _textSecondary,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: _border, height: 1),

                    // ── Pinned Search Field ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: TextField(
                        controller: _pumpSearchController,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID…',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: _muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: _brand,
                            size: 20,
                          ),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _pumpSearchController,
                            builder: (_, value, __) => value.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: _muted,
                                    ),
                                    onPressed: () {
                                      _pumpSearchController.clear();
                                      setDialogState(
                                        () => _filterPumpStations(''),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _brand,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                        ),
                        onChanged: (q) {
                          setDialogState(() => _filterPumpStations(q));
                        },
                      ),
                    ),

                    // ── Pinned Results Count ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            '${_filteredPumpStations.length} station${_filteredPumpStations.length == 1 ? '' : 's'} found',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_filteredPumpStations.isNotEmpty)
                            Text(
                              'Tap to select',
                              style: TextStyle(
                                fontSize: 12,
                                color: _brand.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(color: _border, height: 1),

                    // ── Scrollable List ────────────────────────────────
                    Expanded(
                      child: _filteredPumpStations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 44,
                                    color: Colors.grey[350],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No pump stations match your search',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _filteredPumpStations.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(color: _border, height: 1),
                              itemBuilder: (_, index) {
                                final ps = _filteredPumpStations[index];
                                final isSelected =
                                    _selectedPumpStation?.id == ps.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedPumpStation = ps);
                                    Navigator.of(dialogContext).pop();
                                    _notifySelectionChanged();
                                  },
                                  splashColor: _brand.withOpacity(0.06),
                                  highlightColor: _brand.withOpacity(0.03),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    color: isSelected
                                        ? _brand.withOpacity(0.05)
                                        : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        // ID badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _brand.withOpacity(0.12)
                                                : const Color(0xFFF7FAFC),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? _brand.withOpacity(0.3)
                                                  : _border,
                                            ),
                                          ),
                                          child: Text(
                                            '#${ps.id}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? _brand
                                                  : _textSecondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            ps.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? _brand
                                                  : _textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              Icons.check_circle_rounded,
                                              color: _brand,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _notifySelectionChanged() {
    widget.onSelectionChanged?.call(
      LocationSelection(
        division: _selectedDivision,
        district: _selectedDistrict,
        upazilla: _selectedUpazilla,
        union: _selectedUnion,
        pumpStation: _selectedPumpStation,
      ),
    );
  }

  // ── Standard dropdown (unchanged, used for all location fields) ───────────────

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required bool isLoading,
    bool enabled = true,
    bool nullable = false,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required int Function(T) itemId,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _brand, width: 1.5),
        ),
        suffixIcon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      value: value,
      items: [
        if (nullable)
          DropdownMenuItem<T>(
            value: null,
            child: Text('All', style: TextStyle(color: _muted, fontSize: 14)),
          ),
        ...items.map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              '${itemId(item)} - ${itemLabel(item)}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
      onChanged: enabled && !isLoading ? onChanged : null,
      hint: Text(
        'Select $label',
        style: const TextStyle(fontSize: 14, color: _muted),
      ),
      isExpanded: true,
      validator: widget.enableValidation
          ? (v) => v == null ? 'Please select $label' : null
          : null,
      autovalidateMode: widget.autovalidateMode,
    );
  }

  // ── Searchable pump station field ─────────────────────────────────────────────

  Widget _buildPumpStationField() {
    final bool isEnabled = _canLoadPumpStations && !_loadingPumpStations;
    final bool hasStations = _pumpStations.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: isEnabled && hasStations ? _openPumpSearchDialog : null,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              enabled: isEnabled && hasStations,
              decoration: InputDecoration(
                labelText: 'Pump Station',
                hintText: _getPumpHint(),
                prefixIcon: const Icon(Icons.water_damage_outlined, size: 20),
                suffixIcon: _loadingPumpStations
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: 20,
                        color: isEnabled && hasStations ? _brand : _muted,
                      ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: _brand, width: 1.5),
                ),
              ),
              controller: TextEditingController(
                text: _selectedPumpStation != null
                    ? '${_selectedPumpStation!.name}  (#${_selectedPumpStation!.id})'
                    : '',
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (hasStations && !_loadingPumpStations)
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: _success),
              const SizedBox(width: 4),
              Text(
                '${_pumpStations.length} station${_pumpStations.length == 1 ? '' : 's'} available — tap to search',
                style: const TextStyle(
                  fontSize: 12,
                  color: _success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else if (!_canLoadPumpStations && !_loadingPumpStations)
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: _muted),
              SizedBox(width: 4),
              Text(
                'Select division & district to load stations',
                style: TextStyle(
                  fontSize: 12,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _getPumpHint() {
    if (!_canLoadPumpStations) return 'Select division & district first';
    if (_loadingPumpStations) return 'Loading pump stations…';
    if (_pumpStations.isEmpty) return 'No stations found in this area';
    return 'Tap to search and select station';
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Division
          if (widget.showDivision) ...[
            _buildDropdown<Division>(
              label: 'Division',
              items: _divisions,
              value: _selectedDivision,
              isLoading: _loadingDivisions,
              onChanged: (division) {
                setState(() {
                  _selectedDivision = division;
                  _selectedDistrict = null;
                  _selectedUpazilla = null;
                  _selectedUnion = null;
                  _districts = [];
                  _upazillas = [];
                  _unions = [];
                  _clearPumpStations();
                });
                if (division != null) {
                  _loadDistricts(division.id);
                } else {
                  _notifySelectionChanged();
                }
              },
              itemLabel: (d) => d.name,
              itemId: (d) => d.id,
            ),
            const SizedBox(height: 16),
          ],

          // District
          if (widget.showDistrict) ...[
            _buildDropdown<District>(
              label: 'District',
              items: _districts,
              value: _selectedDistrict,
              isLoading: _loadingDistricts,
              enabled: _selectedDivision != null,
              onChanged: (district) {
                setState(() {
                  _selectedDistrict = district;
                  _selectedUpazilla = null;
                  _selectedUnion = null;
                  _upazillas = [];
                  _unions = [];
                  _clearPumpStations();
                });
                if (district != null) {
                  _loadUpazillas(district.id);
                  // Minimum requirement met — load pump stations
                  if (widget.showPumpStation) _loadPumpStations();
                } else {
                  _notifySelectionChanged();
                }
              },
              itemLabel: (d) => d.name,
              itemId: (d) => d.id,
            ),
            const SizedBox(height: 16),
          ],

          // Upazilla
          if (widget.showUpazilla) ...[
            _buildDropdown<Upazilla>(
              label: widget.showPumpStation
                  ? 'Upazilla (Optional)'
                  : 'Upazilla',
              items: _upazillas,
              value: _selectedUpazilla,
              isLoading: _loadingUpazillas,
              enabled: _selectedDistrict != null,
              // nullable only when pump station mode — upazilla is optional
              nullable: widget.showPumpStation,
              onChanged: (upazilla) {
                setState(() {
                  _selectedUpazilla = upazilla;
                  _selectedUnion = null;
                  _unions = [];
                });
                if (upazilla != null) {
                  _loadUnions(upazilla.id);
                } else {
                  _notifySelectionChanged();
                }
                // Re-fetch stations with updated optional filter
                if (widget.showPumpStation) _loadPumpStations();
              },
              itemLabel: (u) => u.name,
              itemId: (u) => u.id,
            ),
            const SizedBox(height: 16),
          ],

          // Union
          if (widget.showUnion) ...[
            _buildDropdown<Union>(
              label: widget.showPumpStation ? 'Union (Optional)' : 'Union',
              items: _unions,
              value: _selectedUnion,
              isLoading: _loadingUnions,
              enabled: _selectedUpazilla != null,
              nullable: widget.showPumpStation,
              onChanged: (union) {
                setState(() => _selectedUnion = union);
                if (!widget.showPumpStation) {
                  _notifySelectionChanged();
                } else {
                  // Re-fetch stations with updated optional filter
                  _loadPumpStations();
                }
              },
              itemLabel: (u) => u.name,
              itemId: (u) => u.id,
            ),
            if (widget.showPumpStation) const SizedBox(height: 16),
          ],

          // Pump Station — searchable field
          if (widget.showPumpStation) _buildPumpStationField(),
        ],
      ),
    );
  }
}
