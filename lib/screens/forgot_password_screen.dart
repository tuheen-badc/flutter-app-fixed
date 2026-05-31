import 'package:demo_app/common/bloc/forgot_password/forgot_password_state.dart';
import 'package:demo_app/controller/language_change_notifier.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/domain/usecases/verify_forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../common/bloc/forgot_password/forgot_password_state_cubit.dart';
import '../data/models/forgot_password_payload.dart';
import '../data/models/verify_forgot_password_response.dart';
import '../domain/usecases/forgot_password.dart';
import '../l10n/app_localizations.dart';
import '../service_locator.dart';
import 'otp_validator_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final loc = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return '${loc.phoneLabel} is required';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value.trim())) {
      return '${loc.phoneLabel} must be 11 digits';
    }
    return null;
  }

  void _sendOtp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();

      // Trigger forgot password cubit
      context.read<ForgotPasswordCubit>().sendOtp(
        useCase: serviceLocator<ForgotPasswordUseCase>(),
        params: ForgotPasswordPayload(phone: phone),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.forgotPassword),
          actions: [
            Consumer<LanguageChangeController>(
              builder: (_, languageProvider, __) => TextButton.icon(
                onPressed: () => languageProvider.toggleLanguage(),
                icon: Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  languageProvider.isEnglish ? 'বাংলা' : 'English',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccessState) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP has been sent! Please Check.'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to OTP screen with custom success handler
              final payload = ForgotPasswordPayload(
                phone: _phoneController.text.trim(),
              );
              final repo = serviceLocator<AuthRepository>();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OtpValidatorScreen(
                    phone: _phoneController.text.trim(),
                    onResendOtp: () => repo.forgotPassword(payload),
                    useCase: serviceLocator<VerifyForgotPasswordUseCase>(),
                    successMessage: 'OTP verified! Set your new password.',

                    // Custom success handler - Navigate to Reset Password
                    onSuccess: (context, data) {
                      if (data is! VerifyForgotPasswordResponse) {
                        throw Exception(
                          'Invalid type passed to onSuccess. Expected VerifyForgotPasswordResponse',
                        );
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ResetPasswordScreen(
                            resetToken: data.token,
                            phoneNumber: _phoneController.text.trim(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (state is ForgotPasswordErrorState) {
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
            final isLoading = state is ForgotPasswordLoadingState;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_open,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.forgotPassword,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.forgotPasswordDescription,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: loc.phoneLabel,
                          hintText: loc.phoneHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _sendOtp(context),
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
                              : Text(loc.send),
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
