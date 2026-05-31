// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login to App';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => 'e.g. 017XXXXXXXX';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create one';

  @override
  String get accountCreationGuideline => 'Account Creation Guideline';

  @override
  String signingIn(Object phone) {
    return 'Signing in with $phone';
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
