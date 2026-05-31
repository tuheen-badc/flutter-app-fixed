import 'package:demo_app/controller/language_change_notifier.dart';
import 'package:demo_app/screens/forgot_password_screen.dart';
import 'package:demo_app/screens/otp_validator_screen.dart';
import 'package:demo_app/presentation/auth/pages/registration_screen.dart';
import 'package:demo_app/screens/reset_password_screen.dart';
import 'package:demo_app/screens/test_location.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart'; // generated
import 'presentation/auth/pages/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageChangeController()..initializeLanguage(),
        ),
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'My Flutter App',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginScreen(),
            routes: {
              '/register': (context) => const RegistrationScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              // '/validate-otp': (_) => const OtpValidatorScreen(),
              // '/reset-password': (_) => const ResetPasswordScreen(),
            },
          );
        },
      ),
    );
  }
}
