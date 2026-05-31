// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get loginTitle => 'অ্যাপে লগইন করুন';

  @override
  String get phoneLabel => 'ফোন নম্বর';

  @override
  String get phoneHint => 'যেমন: 017XXXXXXXX';

  @override
  String get passwordLabel => 'পাসওয়ার্ড';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get loginButton => 'লগইন';

  @override
  String get noAccount => 'কোনো অ্যাকাউন্ট নেই?';

  @override
  String get createAccount => 'একটি তৈরি করুন';

  @override
  String get accountCreationGuideline => 'Account Creation Guideline';

  @override
  String signingIn(Object phone) {
    return '$phone দিয়ে লগইন করা হচ্ছে';
  }

  @override
  String get forgotPasswordDescription =>
      'An OTP will be sent to this phone number if it exists.';

  @override
  String sendingOtp(Object phone) {
    return 'Sending OTP to $phone…';
  }

  @override
  String get send => 'Send';

  @override
  String get validateOtpTitle => 'Verify OTP';

  @override
  String get enterOtpMessage => 'Please enter the OTP you have received.';

  @override
  String get otpInvalid => 'OTP must be 4 digits';

  @override
  String get submit => 'Submit';

  @override
  String get otpResent => 'resent otp';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordResetSuccess =>
      'Your password has been reset successfully';
}
