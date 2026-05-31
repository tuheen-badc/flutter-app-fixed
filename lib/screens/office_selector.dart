// office_selector.dart
import 'package:flutter/material.dart';

import '../data/models/location.dart';
import '../data/source/location_service.dart';
import '../data/source/office_api_service.dart';

class OfficeSelection {
  final Division? division;
  final District? district;
  final Upazilla? upazilla;
  final Union? union;
  final Office? office;

  const OfficeSelection({
    this.division,
    this.district,
    this.upazilla,
    this.union,
    this.office,
  });
}

class OfficeSelector extends StatefulWidget {
  final OfficeSelection? initialSelection;
  final Function(OfficeSelection)? onSelectionChanged;
  final LocationApiService? locationService;
  final OfficeApiService? officeService;

  const OfficeSelector({
    Key? key,
    this.initialSelection,
    this.onSelectionChanged,
    this.locationService,
    this.officeService,
  }) : super(key: key);

  @override
  State<OfficeSelector> createState() => _OfficeSelectorState();
}

class _OfficeSelectorState extends State<OfficeSelector> {
  late final LocationApiService _locationService;
  late final OfficeApiService _officeService;

  List<Division> _divisions = [];
  List<District> _districts = [];
  List<Upazilla> _upazillas = [];
  List<Union> _unions = [];
  List<Office> _offices = [];
  List<Office> _filteredOffices = [];

  Division? _selectedDivision;
  District? _selectedDistrict;
  Upazilla? _selectedUpazilla;
  Union? _selectedUnion;
  Office? _selectedOffice;

  bool _loadingDivisions = false;
  bool _loadingDistricts = false;
  bool _loadingUpazillas = false;
  bool _loadingUnions = false;
  bool _loadingOffices = false;

  final TextEditingController _searchController = TextEditingController();

  static const _surface = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _muted = Color(0xFFA0AEC0);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);

  bool get _canLoadOffices =>
      _selectedDivision != null && _selectedDistrict != null;

  @override
  void initState() {
    super.initState();
    _locationService =
        widget.locationService ?? LocationApiServiceImplementation();
    _officeService = widget.officeService ?? OfficeApiServiceImplementation();

    if (widget.initialSelection != null) {
      _selectedDivision = widget.initialSelection!.division;
      _selectedDistrict = widget.initialSelection!.district;
      _selectedUpazilla = widget.initialSelection!.upazilla;
      _selectedUnion = widget.initialSelection!.union;
      _selectedOffice = widget.initialSelection!.office;
    }

    _loadDivisions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data loaders ──────────────────────────────────────────────────────────

  Future<void> _loadDivisions() async {
    setState(() => _loadingDivisions = true);
    try {
      final divisions = await _locationService.fetchDivisions();
      setState(() {
        _divisions = divisions;
        _loadingDivisions = false;
        if (_selectedDivision != null) {
          _selectedDivision = _divisions.cast<Division?>().firstWhere(
            (d) => d?.id == _selectedDivision!.id,
            orElse: () => null,
          );
          if (_selectedDivision != null) {
            _loadDistricts(_selectedDivision!.id, isInitial: true);
          }
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
        _clearOffices();
      }
    });
    try {
      final districts = await _locationService.fetchDistricts(divisionId);
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
        if (isInitial && _selectedDistrict != null) {
          _selectedDistrict = _districts.cast<District?>().firstWhere(
            (d) => d?.id == _selectedDistrict!.id,
            orElse: () => null,
          );
          if (_selectedDistrict != null) {
            _loadUpazillas(_selectedDistrict!.id, isInitial: true);
            _loadOffices(isInitial: true);
          }
        }
      });
      if (!isInitial) _notify();
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
      final upazillas = await _locationService.fetchUpazillas(districtId);
      setState(() {
        _upazillas = upazillas;
        _loadingUpazillas = false;
        if (isInitial && _selectedUpazilla != null) {
          _selectedUpazilla = _upazillas.cast<Upazilla?>().firstWhere(
            (u) => u?.id == _selectedUpazilla!.id,
            orElse: () => null,
          );
          if (_selectedUpazilla != null) {
            _loadUnions(_selectedUpazilla!.id, isInitial: true);
          }
        }
      });
      if (!isInitial) _notify();
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
      final unions = await _locationService.fetchUnions(upazillaId);
      setState(() {
        _unions = unions;
        _loadingUnions = false;
        if (isInitial && _selectedUnion != null) {
          _selectedUnion = _unions.cast<Union?>().firstWhere(
            (u) => u?.id == _selectedUnion!.id,
            orElse: () => null,
          );
        }
      });
      if (!isInitial) _notify();
    } catch (_) {
      setState(() => _loadingUnions = false);
      _showError('Failed to load unions');
    }
  }

  Future<void> _loadOffices({bool isInitial = false}) async {
    if (!_canLoadOffices) return;

    setState(() {
      _loadingOffices = true;
      if (!isInitial) _clearOffices();
    });

    try {
      final offices = await _officeService.fetchOffices(
        divisionId: _selectedDivision!.id,
        districtId: _selectedDistrict!.id,
        upazillaId: _selectedUpazilla?.id,
        unionId: _selectedUnion?.id,
      );

      setState(() {
        _offices = offices;
        _filteredOffices = offices;
        _loadingOffices = false;
        if (_selectedOffice != null) {
          _selectedOffice = _offices.cast<Office?>().firstWhere(
            (o) => o?.id == _selectedOffice!.id,
            orElse: () => null,
          );
        }
      });

      if (!isInitial) _notify();
    } catch (_) {
      setState(() => _loadingOffices = false);
      _showError('Failed to load offices');
    }
  }

  void _clearOffices() {
    _offices = [];
    _filteredOffices = [];
    _selectedOffice = null;
  }

  void _filterOffices(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredOffices = q.isEmpty
          ? _offices
          : _offices.where((o) {
              return o.name.toLowerCase().contains(q) ||
                  o.id.toString().contains(q);
            }).toList();
    });
  }

  void _notify() {
    widget.onSelectionChanged?.call(
      OfficeSelection(
        division: _selectedDivision,
        district: _selectedDistrict,
        upazilla: _selectedUpazilla,
        union: _selectedUnion,
        office: _selectedOffice,
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ── Office Search Dialog ──────────────────────────────────────────────────

  void _openOfficeSearchDialog() {
    if (!_canLoadOffices || _offices.isEmpty) return;

    _searchController.clear();
    _filterOffices('');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            // Fixed dialog height — never resizes during search
            final double dialogHeight =
                MediaQuery.of(builderContext).size.height * 0.65;

            return Dialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              child: SizedBox(
                height: dialogHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.business, color: _brand, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Select Office',
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

                    // ── Search Field ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
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
                            valueListenable: _searchController,
                            builder: (_, value, __) => value.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: _muted,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setDialogState(() => _filterOffices(''));
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
                          setDialogState(() => _filterOffices(q));
                        },
                      ),
                    ),

                    // ── Results count (fixed, never moves) ───────────────
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_filteredOffices.length} of ${_offices.length} office${_offices.length == 1 ? '' : 's'} found',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_filteredOffices.isNotEmpty)
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

                    // ── Office List — fills remaining fixed space ─────────
                    Expanded(
                      child: _filteredOffices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No offices match your search',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: _filteredOffices.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(color: _border, height: 1),
                              itemBuilder: (_, index) {
                                final office = _filteredOffices[index];
                                final isSelected =
                                    _selectedOffice?.id == office.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedOffice = office);
                                    Navigator.of(dialogContext).pop();
                                    _notify();
                                  },
                                  child: Padding(
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
                                            '#${office.id}',
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

                                        // Office name
                                        Expanded(
                                          child: Text(
                                            office.name,
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
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: _brand,
                                            size: 20,
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

  // ── Widget tree ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown<Division>(
          label: 'Division',
          items: _divisions,
          value: _selectedDivision,
          isLoading: _loadingDivisions,
          enabled: true,
          onChanged: (division) {
            setState(() {
              _selectedDivision = division;
              _selectedDistrict = null;
              _selectedUpazilla = null;
              _selectedUnion = null;
              _districts = [];
              _upazillas = [];
              _unions = [];
              _clearOffices();
            });
            if (division != null) {
              _loadDistricts(division.id);
            } else {
              _notify();
            }
          },
          itemLabel: (d) => d.name,
          itemId: (d) => d.id,
        ),
        const SizedBox(height: 16),

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
              _clearOffices();
            });
            if (district != null) {
              _loadUpazillas(district.id);
              _loadOffices();
            } else {
              _notify();
            }
          },
          itemLabel: (d) => d.name,
          itemId: (d) => d.id,
        ),
        const SizedBox(height: 16),

        _buildDropdown<Upazilla>(
          label: 'Upazilla (Optional)',
          items: _upazillas,
          value: _selectedUpazilla,
          isLoading: _loadingUpazillas,
          enabled: _selectedDistrict != null,
          nullable: true,
          onChanged: (upazilla) {
            setState(() {
              _selectedUpazilla = upazilla;
              _selectedUnion = null;
              _unions = [];
            });
            if (upazilla != null) _loadUnions(upazilla.id);
            _loadOffices();
          },
          itemLabel: (u) => u.name,
          itemId: (u) => u.id,
        ),
        const SizedBox(height: 16),

        _buildDropdown<Union>(
          label: 'Union (Optional)',
          items: _unions,
          value: _selectedUnion,
          isLoading: _loadingUnions,
          enabled: _selectedUpazilla != null,
          nullable: true,
          onChanged: (union) {
            setState(() => _selectedUnion = union);
            _loadOffices();
          },
          itemLabel: (u) => u.name,
          itemId: (u) => u.id,
        ),
        const SizedBox(height: 16),

        _buildOfficeField(),
      ],
    );
  }

  Widget _buildOfficeField() {
    final bool isEnabled = _canLoadOffices && !_loadingOffices;
    final bool hasOffices = _offices.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: isEnabled && hasOffices ? _openOfficeSearchDialog : null,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              enabled: isEnabled && hasOffices,
              decoration: InputDecoration(
                labelText: 'Office',
                hintText: _getOfficeHint(),
                prefixIcon: const Icon(Icons.business_outlined, size: 20),
                suffixIcon: _loadingOffices
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
                        color: isEnabled && hasOffices ? _brand : _muted,
                      ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: _brand, width: 1.5),
                ),
              ),
              controller: TextEditingController(
                text: _selectedOffice != null
                    ? '${_selectedOffice!.name}  (#${_selectedOffice!.id})'
                    : '',
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        if (hasOffices && !_loadingOffices)
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: _success),
              const SizedBox(width: 4),
              Text(
                '${_offices.length} office${_offices.length == 1 ? '' : 's'} available — tap to search',
                style: const TextStyle(
                  fontSize: 12,
                  color: _success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else if (!_canLoadOffices && !_loadingOffices)
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: _muted),
              SizedBox(width: 4),
              Text(
                'Select division & district to load offices',
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

  String _getOfficeHint() {
    if (!_canLoadOffices) return 'Select division & district first';
    if (_loadingOffices) return 'Loading offices…';
    if (_offices.isEmpty) return 'No offices found in this area';
    return 'Tap to search and select office';
  }

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
    );
  }
}
