// presentation/official_registration_tabs/new_registration_tab.dart
import 'package:demo_app/data/models/official_pre_registration_payload.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/pre_registration/official_pre_registration_create_state.dart';
import '../../common/bloc/pre_registration/official_pre_registration_create_state_cubit.dart';
import '../../domain/usecases/pre_registration_create.dart';

class NewRegistrationTab extends StatefulWidget {
  final VoidCallback onRegistrationSuccess;
  final int officeId;
  final UserRole registrationRole;

  const NewRegistrationTab({
    Key? key,

    required this.onRegistrationSuccess,
    required this.officeId,
    required this.registrationRole,
  }) : super(key: key);

  @override
  State<NewRegistrationTab> createState() => _NewRegistrationTabState();
}

class _NewRegistrationTabState extends State<NewRegistrationTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitRegistration(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final payload = OfficialPreRegistrationPayload(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        registrationRole: widget.registrationRole.name,
        officeId: widget.officeId,
      );

      context.read<OfficialPreRegistrationCreateCubit>().createRegistration(
        useCase: serviceLocator<OfficialPreRegistrationCreateUseCase>(),
        params: payload,
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfficialPreRegistrationCreateCubit(),
      child:
          BlocListener<
            OfficialPreRegistrationCreateCubit,
            OfficialPreRegistrationCreateState
          >(
            listener: (context, state) {
              if (state is OfficialPreRegistrationCreateSuccessState) {
                // Clear form
                _clearForm();

                // Show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: _success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Switch to Registration History tab using callback
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    widget.onRegistrationSuccess();
                    context
                        .read<OfficialPreRegistrationCreateCubit>()
                        .resetState();
                  }
                });
              } else if (state is OfficialPreRegistrationCreateFailureState) {
                // Show error snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: _danger,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );

                context.read<OfficialPreRegistrationCreateCubit>().resetState();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _brand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: _brand,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Pre-Registration',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pre-Register a new ${widget.registrationRole.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Enter full name',
                              hintStyle: const TextStyle(
                                color: _textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: _textSecondary,
                              ),
                              filled: true,
                              fillColor: _bg,
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
                                borderSide: const BorderSide(
                                  color: _brand,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: _danger),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _danger,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the full name';
                              }
                              if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Phone Field
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: const TextStyle(
                                color: _textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: _textSecondary,
                              ),
                              filled: true,
                              fillColor: _bg,
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
                                borderSide: const BorderSide(
                                  color: _brand,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: _danger),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _danger,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the phone number';
                              }
                              // Basic phone validation - adjust regex as needed
                              final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
                              if (!phoneRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid phone number';
                              }
                              if (value
                                      .trim()
                                      .replaceAll(RegExp(r'[^0-9]'), '')
                                      .length <
                                  10) {
                                return 'Phone number must be at least 10 digits';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Role Info Badge
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _brand.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _brand.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: _brand,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Registration Role: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _brand,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.registrationRole.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          BlocBuilder<
                            OfficialPreRegistrationCreateCubit,
                            OfficialPreRegistrationCreateState
                          >(
                            builder: (context, state) {
                              final isLoading =
                                  state
                                      is OfficialPreRegistrationCreateLoadingState;

                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _submitRegistration(context),
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: _brand,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                        disabledBackgroundColor: _textSecondary
                                            .withOpacity(0.5),
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStateProperty.resolveWith(
                                              (states) =>
                                                  Colors.white.withOpacity(
                                                    states.contains(
                                                          WidgetState.pressed,
                                                        )
                                                        ? 0.08
                                                        : 0.04,
                                                  ),
                                            ),
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
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_add, size: 20),
                                            SizedBox(width: 10),
                                            Text(
                                              'Create Registration',
                                              style: TextStyle(
                                                fontSize: 15,
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

                          const SizedBox(height: 12),

                          // Clear Button
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _clearForm,
                              style:
                                  TextButton.styleFrom(
                                    foregroundColor: _textSecondary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(
                                      Colors.black.withOpacity(0.04),
                                    ),
                                  ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.clear, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Clear Form',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
