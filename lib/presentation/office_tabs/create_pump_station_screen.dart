// screens/create_pump_station_screen.dart

import 'package:demo_app/data/models/location.dart';
import 'package:demo_app/data/models/pump_station_creation_payload.dart';
import 'package:demo_app/screens/location_selector.dart';
import 'package:demo_app/screens/pump_tabs_container.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/create_pump/create_pump_state.dart';
import '../../common/bloc/create_pump/create_pump_state_cubit.dart';
import '../../data/models/user_info.dart';
import '../../domain/usecases/create_pump_station.dart';

// import 'package:demo_app/screens/pump_station_tabs_screen.dart';

class CreatePumpStationScreen extends StatefulWidget {
  final User user;
  final int officeId;
  final String officeName;

  const CreatePumpStationScreen({
    Key? key,
    required this.user,
    required this.officeId,
    required this.officeName,
  }) : super(key: key);

  @override
  State<CreatePumpStationScreen> createState() =>
      _CreatePumpStationScreenState();
}

class _CreatePumpStationScreenState extends State<CreatePumpStationScreen> {
  static const _bg = Color(0xFFF8F9FA);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _muted = Color(0xFFA0AEC0);

  final _formKey = GlobalKey<FormState>();
  LocationSelection _locationSelection = LocationSelection();
  final _managerPhoneCtrl = TextEditingController();
  final _dataProviderPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _managerPhoneCtrl.dispose();
    _dataProviderPhoneCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_locationSelection.division == null ||
        _locationSelection.district == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least Division and District.'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<CreatePumpCubit>().createPump(
      useCase: serviceLocator<CreatePumpStationUseCase>(),
      params: PumpStationCreationPayload(
        divisionId: _locationSelection.division!.id,
        districtId: _locationSelection.district!.id,
        upazillaId: _locationSelection.upazilla?.id,
        unionId: _locationSelection.union?.id,
        officeId: widget.officeId,
        managerPhone: _managerPhoneCtrl.text.trim().isEmpty
            ? null
            : _managerPhoneCtrl.text.trim(),
        dataProviderPhone: _dataProviderPhoneCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePumpCubit(),
      child: Builder(
        builder: (ctx) => BlocListener<CreatePumpCubit, CreatePumpState>(
          listener: (context, state) {
            if (state is CreatePumpSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pump station "${state.createdStation.name}" created!',
                  ),
                  backgroundColor: _success,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PumpActionScreen(
                    userData: widget.user,
                    pumpStationId: state.createdStation.id,
                    pumpStationName: state.createdStation.name,
                  ),
                ),
              );
            } else if (state is CreatePumpErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: _danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<CreatePumpCubit>().resetState();
            }
          },
          child: Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Pump Station',
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
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // ── Location ───────────────────────────────────────────
                  const _SectionHeader(
                    icon: Icons.location_on,
                    iconColor: Color(0xFFEF4444),
                    title: 'Location',
                    subtitle: 'Division and District are required',
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: LocationSelector(
                      initialSelection: _locationSelection,
                      onSelectionChanged: (selection) =>
                          setState(() => _locationSelection = selection),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Contact ────────────────────────────────────────────
                  const _SectionHeader(
                    icon: Icons.phone,
                    iconColor: Color(0xFF10B981),
                    title: 'Contact',
                    subtitle:
                        'Manager phone is optional · Data provider phone is required',
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      children: [
                        _PhoneField(
                          controller: _managerPhoneCtrl,
                          label: 'Manager Phone (Optional)',
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF10B981),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return null;
                            if (val.trim().length != 11) {
                              return 'Phone number must be exactly 11 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _PhoneField(
                          controller: _dataProviderPhoneCtrl,
                          label: 'Data Provider Phone',
                          icon: Icons.cell_tower,
                          iconColor: const Color(0xFF8B5CF6),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Data provider phone is required';
                            }
                            if (val.trim().length != 11) {
                              return 'Phone number must be exactly 11 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Submit ─────────────────────────────────────────────
                  BlocBuilder<CreatePumpCubit, CreatePumpState>(
                    builder: (context, state) {
                      final isLoading = state is CreatePumpLoadingState;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _muted,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Create Pump Station',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
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

// =============================================================================
// Helpers
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
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
                  color: Color(0xFF2D3748),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String? Function(String?)? validator;

  const _PhoneField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '01XXXXXXXXX',
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3182CE), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }
}
