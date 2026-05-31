// screens/update_phone_screen.dart
import 'package:demo_app/common/bloc/update_phone/update_phone_state.dart';
import 'package:demo_app/common/bloc/update_phone/update_phone_state_cubit.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/domain/usecases/update_phone.dart';
import 'package:demo_app/domain/usecases/user_info.dart';
import 'package:demo_app/domain/usecases/verify_phone_update.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/presentation/home/pages/home_screen.dart';
import 'package:demo_app/screens/otp_validator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/common_top_bar.dart';
import '../../../service_locator.dart';
import '../../drawer/drawer_config.dart';

class UpdatePhoneScreen extends StatefulWidget {
  final User userData;

  const UpdatePhoneScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController newPhoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newPhoneController.dispose();
    super.dispose();
  }

  void _updatePhone(BuildContext ctx) {
    if (formKey.currentState!.validate()) {
      ctx.read<UpdatePhoneButtonStateCubit>().updatePhone(
        useCase: serviceLocator<UpdatePhoneUseCase>(),
        params: UpdatePhonePayload(
          newPhoneNumber: newPhoneController.text.trim(),
        ),
      );
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    // Check if it's the same as current phone (if available)
    if (widget.userData.phone != null &&
        value.trim() == widget.userData.phone) {
      return 'New phone number must be different from current number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UpdatePhoneScreenCubit()),
        BlocProvider(create: (context) => UpdatePhoneButtonStateCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdatePhoneButtonStateCubit, UpdatePhoneButtonState>(
            listener: (context, state) {
              if (state is UpdatePhoneButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP has been sent! Please Check.'),
                    backgroundColor: Colors.green,
                  ),
                );

                final payload = UpdatePhonePayload(
                  newPhoneNumber: newPhoneController.text.trim(),
                );

                final repo = serviceLocator<UserRepository>();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OtpValidatorScreen(
                      phone: newPhoneController.text.trim(),
                      onResendOtp: () => repo.updatePhone(payload),
                      useCase: serviceLocator<VerifyPhoneUpdateUseCase>(),
                      successMessage: 'Phone number updated successfully!',

                      // Custom success handler - Navigate to Home Screen
                      onSuccess: (context, data) {
                        // data contains the updated user info from API
                        // Example API response: { "user": {...}, "message": "..." }

                        // Navigate to HomeScreen and clear stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                );
              } else if (state is UpdatePhoneButtonFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FA),
          drawer: RoleBasedDrawer(
            userData: widget.userData,
            initialActiveItem: DrawerMenuItem.userManagement,
          ),
          appBar: CustomTopBar(
            title: 'Update Phone',
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          body: BlocBuilder<UpdatePhoneScreenCubit, UpdatePhoneScreenState>(
            builder: (context, screenState) {
              if (screenState is UpdatePhoneScreenLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (screenState is UpdatePhoneScreenFailureState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        screenState.errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UpdatePhoneScreenCubit>().loadPhone(
                            useCase: serviceLocator<UserInfoUseCase>(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (screenState is UpdatePhoneScreenSuccessState) {}

              // Initial state or fallback
              return _buildContent(context, widget.userData);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, User userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Update Your Phone Number',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your new phone number',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Current Phone Display (if available)
            if (userProfile.phone != null && userProfile.phone!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Phone',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userProfile.phone!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // New Phone Number Field
            TextFormField(
              controller: newPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+\(\)]')),
              ],
              decoration: InputDecoration(
                labelText: 'New Phone Number',
                hintText: 'Enter your new phone number',
                prefixIcon: const Icon(Icons.phone_android_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => _validatePhoneNumber(value),
            ),
            const SizedBox(height: 20),

            // Update Phone Button
            BlocBuilder<UpdatePhoneButtonStateCubit, UpdatePhoneButtonState>(
              builder: (context, buttonState) {
                return ElevatedButton(
                  onPressed: buttonState is UpdatePhoneButtonLoadingState
                      ? null
                      : () => _updatePhone(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF3182CE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: buttonState is UpdatePhoneButtonLoadingState
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Updating...'),
                          ],
                        )
                      : const Text(
                          'Update Phone Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You will receive an OTP to verify your new phone number. Make sure it is active and accessible.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
