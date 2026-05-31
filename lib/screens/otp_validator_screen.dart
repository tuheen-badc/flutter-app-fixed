import 'dart:async';

import 'package:dartz/dartz.dart' as dartz;
import 'package:demo_app/common/bloc/otp_validation/verify_otp_button_state.dart';
import 'package:demo_app/common/bloc/otp_validation/verify_otp_button_state_cubit.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../l10n/app_localizations.dart';
import '../presentation/home/pages/home_screen.dart';
class OtpValidatorScreen extends StatefulWidget {
  /// Resend OTP callback provided by the originating screen/flow.
  /// Should return Right(Response) on success or Left(errorMessage) on failure.
  final Future<dartz.Either> Function()? onResendOtp;

  /// UseCase to verify OTP
  final UseCase useCase;

  final String phone;

  /// Callback when OTP verification succeeds
  /// Receives the context and API response data
  /// If not provided, defaults to navigating to HomeScreen
  final void Function(BuildContext context, dynamic data)? onSuccess;

  /// Optional custom success message
  /// If not provided, defaults to "Password changed successfully!"
  final String? successMessage;

  const OtpValidatorScreen({
    super.key,
    required this.phone,
    required this.onResendOtp,
    required this.useCase,
    this.onSuccess,
    this.successMessage,
  });

  @override
  State<OtpValidatorScreen> createState() => _OtpValidatorScreenState();
}

class _OtpValidatorScreenState extends State<OtpValidatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final PinInputController _pinController = PinInputController();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 10; // 3 minutes in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 10;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitOtp(BuildContext ctx) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    verify(ctx);
  }

  void verify(BuildContext ctx) {
    ctx.read<VerifyOtpButtonStateCubit>().execute(
      useCase: widget.useCase,
      params: VerifyOtpPayload(phone: widget.phone, otpCode: _pinController.text),
    );
  }

  Future<void> _resendOtp() async {
    if (!_canResend || widget.onResendOtp == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await widget.onResendOtp!();

      if (!mounted) return;
      res.fold(
        (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.otpResent,
              ),
              backgroundColor: Colors.green,
            ),
          );
          _startResendTimer(); // restart countdown after success
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => VerifyOtpButtonStateCubit(),
      child: BlocListener<VerifyOtpButtonStateCubit, VerifyOtpButtonState>(
        listener: (context, state) {
          if (state is VerifyOtpButtonSuccessState) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.successMessage ?? 'Password changed successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Call custom success callback OR default to HomeScreen
            if (widget.onSuccess != null) {
              widget.onSuccess!(context, state.data);
            } else {
              // Default behavior: Navigate to HomeScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else if (state is VerifyOtpButtonFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        child: Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(loc.validateOtpTitle),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            foregroundColor: colorScheme.onSurface,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight -
                      32,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Verify Your Account',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            loc.enterOtpMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // OTP input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MaterialPinFormField(
                            pinController: _pinController,
                            length: 4,
                            autoFocus: true,
                            keyboardType: TextInputType.number,
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.outlined,
                              borderRadius: BorderRadius.circular(12),
                              cellSize: const Size(50, 60),
                              fillColor: colorScheme.surfaceContainerHighest,
                              focusedFillColor: colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              filledFillColor: colorScheme.primaryContainer,
                              borderColor: colorScheme.outline,
                              focusedBorderColor: colorScheme.primary,
                              filledBorderColor: colorScheme.primary,
                              borderWidth: 2,
                              focusedBorderWidth: 2,
                              textStyle: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              entryAnimation: MaterialPinAnimation.fade,
                              animationDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                            onChanged: (_) {},
                            onCompleted: (_) {},
                            validator: (value) {
                              if (value == null || value.trim().length < 4) {
                                return loc.otpInvalid;
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit Button with BlocBuilder
                        BlocBuilder<
                          VerifyOtpButtonStateCubit,
                          VerifyOtpButtonState
                        >(
                          builder: (context, state) {
                            final isLoading =
                                state is VerifyOtpButtonLoadingState;

                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _submitOtp(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        loc.submit,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Resend section
                        Column(
                          children: [
                            if (!_canResend)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Resend available in ${_formatTime(_resendCountdown)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _canResend && !_isLoading
                                      ? _resendOtp
                                      : null,
                                  style: TextButton.styleFrom(
                                    foregroundColor: _canResend
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _canResend
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
