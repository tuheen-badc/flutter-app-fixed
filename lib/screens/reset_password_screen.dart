// lib/screens/reset_password_screen.dart
import 'package:demo_app/common/bloc/reset_password/reset_password_state.dart';
import 'package:demo_app/data/models/reset_password_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/reset_password/reset_password_state_cubit.dart';
import '../domain/usecases/reset_password.dart';
import '../l10n/app_localizations.dart';
import '../presentation/auth/pages/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;
  final String phoneNumber;

  const ResetPasswordScreen({
    Key? key,
    required this.resetToken,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _resetPassword(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _passwordCtrl.text.trim();

      // Trigger reset password cubit
      context.read<ResetPasswordCubit>().resetPassword(
        useCase: serviceLocator<ResetPasswordUseCase>(),
        params: ResetPasswordPayload(
          token: widget.resetToken,
          newPassword: newPassword,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    final loc = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return '${loc.passwordLabel} is required';
    }
    if (value.trim().length < 6) {
      return loc.passwordLengthError;
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final loc = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return '${loc.confirmPasswordLabel} is required';
    }
    if (value.trim() != _passwordCtrl.text.trim()) {
      return loc.passwordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ResetPasswordCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(loc.resetPasswordTitle)),
        body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccessState) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.passwordResetSuccess),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to login and clear stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            } else if (state is ResetPasswordErrorState) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ResetPasswordLoadingState;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Icon
                      Icon(
                        Icons.lock_reset,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        loc.resetPasswordTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle with phone
                      Text(
                        'Set new password for ${widget.phoneNumber}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // New Password Field
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: loc.passwordLabel,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirmPassword,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: loc.confirmPasswordLabel,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: _validateConfirm,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _resetPassword(context),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(loc.submit),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
