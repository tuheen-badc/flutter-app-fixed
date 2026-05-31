import 'package:demo_app/common/bloc/login/login_state.dart';
import 'package:demo_app/common/bloc/login/login_state_cubit.dart';
import 'package:demo_app/controller/language_change_notifier.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/domain/usecases/login.dart';
import 'package:demo_app/screens/account_blocked_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../service_locator.dart';
import '../../home/pages/home_screen.dart';

class LoginScreen extends StatefulWidget with RouteAware {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final String phone = _phoneController.text.trim();

      context.read<LoginButtonStateCubit>().execute(
        useCase: serviceLocator<LoginUseCase>(),
        params: LoginPayload(
          phone: _phoneController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  String? _validatePhone(String? value) {
    // final loc = AppLocalizations.of(context)!;
    // if (value == null || value.isEmpty) {
    //   return '${loc.phoneLabel} is required';
    // }
    // final RegExp regex = RegExp(r'^\d{11}$');
    // if (!regex.hasMatch(value.trim())) {
    //   return '${loc.phoneLabel} must be 11 digits';
    // }
    // return null;
  }

  String? _validatePassword(String? value) {
    final loc = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return '${loc.passwordLabel} is required';
    }
    return null;
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _goToAccountCreationGuideline() {
    Navigator.pushNamed(context, '/account-creation-guideline');
  }

  void _forgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.loginTitle),
        actions: [
          Consumer<LanguageChangeController>(
            builder: (context, languageProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () async {
                    await languageProvider.toggleLanguage();
                  },
                  icon: Icon(
                    Icons.language,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  label: Text(
                    languageProvider.isEnglish ? 'বাংলা' : 'English',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: BlocProvider(
        create: (context) => LoginButtonStateCubit(),
        child: BlocListener<LoginButtonStateCubit, LoginButtonState>(
          listener: (context, state) {
            if (state is LoginSuccessState) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
            if (state is LoginFailureState) {
              if (state.errorModel.errorKey == "BLOCKED_USER") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountBlockedScreen(),
                  ),
                );
              } else {
                var snackBar = SnackBar(
                  content: Text(state.errorModel.message),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              context.read<LoginButtonStateCubit>().reset();
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.loginTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPhoneWidget(loc),
                    const SizedBox(height: 16),
                    _buildPasswordWidget(loc),
                    const SizedBox(),
                    _buildForgotPasswordLink(loc),
                    const SizedBox(height: 16),
                    _buildLoginButtonWidget(context, loc),
                    const SizedBox(height: 16),
                    _buildCreateAccountGuidelineWidget(loc),
                    const SizedBox(height: 16),
                    _buildCreateAccountWidget(loc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountGuidelineWidget(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _goToAccountCreationGuideline,
          child: Text(
            loc.accountCreationGuideline,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountWidget(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(loc.noAccount),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _goToRegister,
          child: Text(
            loc.createAccount,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtonWidget(
    BuildContext buildContext,
    AppLocalizations loc,
  ) {
    return Builder(
      builder: (buildContext) {
        return BlocBuilder<LoginButtonStateCubit, LoginButtonState>(
          builder: (context, state) {
            if (state is LoginButtonLoadingState) {
              return _loadingLoginButton(loc);
            }
            return _initialLoginButton(buildContext, loc);
          },
        );
      },
    );
  }

  Widget _loadingLoginButton(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _initialLoginButton(BuildContext context, AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _signIn(context),
        child: Text(loc.loginButton),
      ),
    );
  }

  Widget _buildForgotPasswordLink(AppLocalizations loc) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _forgotPassword,
        child: Text(loc.forgotPassword),
      ),
    );
  }

  Widget _buildPasswordWidget(AppLocalizations loc) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: loc.passwordLabel,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: _validatePassword,
    );
  }

  Widget _buildPhoneWidget(AppLocalizations loc) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: loc.phoneLabel,
        hintText: loc.phoneHint,
        border: const OutlineInputBorder(),
      ),
      validator: _validatePhone,
    );
  }
}
