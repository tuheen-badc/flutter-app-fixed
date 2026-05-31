import 'package:demo_app/common/bloc/create_office/create_office_state.dart';
import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/office_creation_payload.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/screens/office_overview_screen.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/create_office/create_office_state_cubit.dart';
import '../../domain/usecases/create_office.dart';

class CreateOfficeScreen extends StatefulWidget {
  final User userData;

  const CreateOfficeScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<CreateOfficeScreen> createState() => _CreateOfficeScreenState();
}

class _CreateOfficeScreenState extends State<CreateOfficeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  // Location selection state
  Division? _selectedDivision;
  District? _selectedDistrict;
  Upazilla? _selectedUpazilla;
  Union? _selectedUnion;

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _muted = Color(0xFFA0AEC0);

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _isLocationValid =>
      _selectedDivision != null && _selectedDistrict != null;

  void _onSelectionChanged(LocationSelection selection) {
    setState(() {
      _selectedDivision = selection.division;
      _selectedDistrict = selection.district;
      _selectedUpazilla = selection.upazilla;
      _selectedUnion = selection.union;
    });
  }

  void _submit(BuildContext providerContext) {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLocationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least Division and District.'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final payload = OfficeCreationPayload(
      name: _nameController.text.trim(),
      divisionId: _selectedDivision!.id,
      districtId: _selectedDistrict!.id,
      upazillaId: _selectedUpazilla?.id,
      unionId: _selectedUnion?.id,
      contactNumber: _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
    );

    providerContext.read<CreateOfficeCubit>().createOffice(
      useCase: serviceLocator<CreateOfficeUseCase>(),
      params: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateOfficeCubit(),
      child: Builder(
        builder: (providerContext) {
          return BlocListener<CreateOfficeCubit, CreateOfficeState>(
            listener: (context, state) {
              if (state is CreateOfficeSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '"${state.office.name}" office created successfully!',
                    ),
                    backgroundColor: _success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Navigate to Office Quick Actions screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OfficeOverviewScreen(
                      officeId: state.office.id,
                      officeName: state.office.name,
                      user: widget.userData,
                    ),
                  ),
                );
              } else if (state is CreateOfficeErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: _danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                context.read<CreateOfficeCubit>().resetState();
              }
            },
            child: Scaffold(
              backgroundColor: _bg,
              appBar: AppBar(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  'Create Office',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              body: BlocBuilder<CreateOfficeCubit, CreateOfficeState>(
                builder: (context, state) {
                  final isLoading = state is CreateOfficeLoadingState;

                  return AbsorbPointer(
                    absorbing: isLoading,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // ── Office Details Card ───────────────────────
                          _SectionCard(
                            title: 'Office Details',
                            icon: Icons.business_outlined,
                            children: [
                              _FieldLabel(label: 'Office Name', required: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'e.g. Dhaka Central Office',
                                  icon: Icons.business,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Office name is required';
                                  }
                                  if (val.trim().length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _FieldLabel(
                                label: 'Contact Number',
                                required: false,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _contactController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'e.g. 01700000000 (optional)',
                                  icon: Icons.phone_outlined,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return null; // optional
                                  }
                                  if (val.trim().length < 10) {
                                    return 'Enter a valid contact number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Location Card ─────────────────────────────
                          _SectionCard(
                            title: 'Location',
                            icon: Icons.location_on_outlined,
                            subtitle:
                                'Division & District are required. Upazilla & Union are optional.',
                            children: [
                              LocationSelector(
                                initialSelection: LocationSelection(
                                  division: _selectedDivision,
                                  district: _selectedDistrict,
                                  upazilla: _selectedUpazilla,
                                  union: _selectedUnion,
                                ),
                                onSelectionChanged: _onSelectionChanged,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ── Submit Button ─────────────────────────────
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _submit(providerContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brand,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _muted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_business, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Create Office',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: _muted,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, size: 20, color: _textSecondary),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _danger, width: 1.5),
      ),
    );
  }
}

// ── Section Card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;

  static const _surface = Color(0xFFFFFFFF);
  static const _border = Color(0xFFE2E8F0);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _brand = Color(0xFF3182CE);

  const _SectionCard({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: _brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 20),

            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  static const _textPrimary = Color(0xFF2D3748);
  static const _danger = Color(0xFFEF4444);
  static const _muted = Color(0xFFA0AEC0);

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 4),
        if (required)
          const Text(
            '*',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _danger,
            ),
          )
        else
          const Text(
            '(optional)',
            style: TextStyle(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}

// ── Location Summary ─────────────────────────────────────────────────────────

class _LocationSummary extends StatelessWidget {
  final Division? division;
  final District? district;
  final Upazilla? upazilla;
  final Union? union;

  static const _border = Color(0xFFE2E8F0);
  static const _success = Color(0xFF10B981);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);

  const _LocationSummary({
    required this.division,
    required this.district,
    this.upazilla,
    this.union,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _success.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: _success),
              const SizedBox(width: 8),
              const Text(
                'Location Selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (division != null)
                _LocationChip(label: division!.name, sublabel: 'Division'),
              if (district != null)
                _LocationChip(label: district!.name, sublabel: 'District'),
              if (upazilla != null)
                _LocationChip(label: upazilla!.name, sublabel: 'Upazilla'),
              if (union != null)
                _LocationChip(label: union!.name, sublabel: 'Union'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final String sublabel;

  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);

  const _LocationChip({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 10,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
