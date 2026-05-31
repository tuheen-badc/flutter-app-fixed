// screens/change_password_screen.dart
import 'package:demo_app/common/bloc/update_password/update_password_state.dart';
import 'package:demo_app/common/bloc/update_password/update_password_state_cubit.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/domain/usecases/update_password.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/common_top_bar.dart';
import '../../../service_locator.dart';
import '../../drawer/drawer_config.dart';
import '../../home/pages/home_screen.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final User userData;

  const UpdatePasswordScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _changePassword(BuildContext ctx) {
    if (formKey.currentState!.validate()) {
      ctx.read<UpdatePasswordButtonStateCubit>().updatePassword(
        useCase: serviceLocator<UpdatePasswordUseCase>(),
        params: UpdatePasswordPayload(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
          confirmNewPassword: confirmNewPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdatePasswordButtonStateCubit(),
      child:
          BlocListener<
            UpdatePasswordButtonStateCubit,
            UpdatePasswordButtonState
          >(
            listener: (context, state) {
              if (state is UpdatePasswordButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to HomeScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomeScreen(), // Replace with your HomeScreen
                  ),
                );
              } else if (state is UpdatePasswordButtonFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: const Color(0xFFF8F9FA),
              drawer: RoleBasedDrawer(
                userData: widget.userData,
                initialActiveItem: DrawerMenuItem.userManagement,
              ),
              appBar: CustomTopBar(
                title: 'Change Password',
                onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Change Your Password',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your current password and choose a new one',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Current Password Field
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: !_isCurrentPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCurrentPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCurrentPasswordVisible =
                                    !_isCurrentPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // New Password Field
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (value == currentPasswordController.text) {
                            return 'New password must be different from current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm New Password Field
                      TextFormField(
                        controller: confirmNewPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Change Password Button
                      BlocBuilder<
                        UpdatePasswordButtonStateCubit,
                        UpdatePasswordButtonState
                      >(
                        builder: (context, buttonState) {
                          return ElevatedButton(
                            onPressed:
                                buttonState is UpdatePasswordButtonLoadingState
                                ? null
                                : () => _changePassword(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF3182CE),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                buttonState is UpdatePasswordButtonLoadingState
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Changing...'),
                                    ],
                                  )
                                : const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
