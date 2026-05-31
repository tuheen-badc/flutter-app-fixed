import 'package:demo_app/common/bloc/sign_up/sign_up_state.dart';
import 'package:demo_app/common/bloc/sign_up/sign_up_state_cubit.dart';
import 'package:demo_app/data/models/signup_payload.dart';
import 'package:demo_app/domain/usecases/sign_up.dart';
import 'package:demo_app/domain/usecases/verify_registration.dart';
import 'package:demo_app/presentation/auth/pages/login_screen.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repository/auth.dart';
import '../../../screens/otp_validator_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  DateTime? _selectedDob;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First Name is required';
    }
    if (value.trim().length > 64) {
      return 'First Name must be at most 64 characters';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last Name is required';
    }
    if (value.trim().length > 64) {
      return 'Last Name must be at most 64 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required';
    }
    final RegExp regex = RegExp(r'^\d{11}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Phone Number must be 11 digits';
    }
    return null;
  }

  String? _validateDob(String? value) {
    if (_selectedDob == null) {
      return 'Date of Birth is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 64) {
      return 'Password must be at most 64 characters';
    }
    return null;
  }

  Future<void> _pickDob() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _register(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<SignUpButtonStateCubit>().execute(
        useCase: serviceLocator<SignUpUseCase>(),
        params: SignUpPayload(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          dob: _dobController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocProvider(
        create: (context) => SignUpButtonStateCubit(),
        child: BlocListener<SignUpButtonStateCubit, SignUpButtonState>(
          listener: (context, state) {
            if (state is SignUpSuccessState) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP has been sent! Please Check.'),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to OTP screen with custom success handler
              final payload = SignUpPayload(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
                dob: _dobController.text,
              );

              final repo = serviceLocator<AuthRepository>();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OtpValidatorScreen(
                    phone: _phoneController.text.trim(),
                    onResendOtp: () => repo.signup(payload),
                    useCase: serviceLocator<VerifyRegistrationUseCase>(),
                    successMessage: 'OTP verified! Please login.',
                    onSuccess: (context, data) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                  ),
                ),
              );
            }
            if (state is SignUpFailureState) {
              var snackBar = SnackBar(content: Text(state.errorMessage));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                      Icons.person_add_alt_1_rounded,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildFirstNameWidget(),
                    const SizedBox(height: 16),
                    _buildLastNameWidget(),
                    const SizedBox(height: 16),
                    _buildPhoneWidget(),
                    const SizedBox(height: 16),
                    _buildDobWidget(),
                    const SizedBox(height: 16),
                    _buildPasswordWidget(),
                    const SizedBox(height: 24),
                    _buildSignUpButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameWidget() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name',
        border: OutlineInputBorder(),
      ),
      validator: _validateFirstName,
    );
  }

  Widget _buildLastNameWidget() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        border: OutlineInputBorder(),
      ),
      validator: _validateLastName,
    );
  }

  Widget _buildPhoneWidget() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
      validator: _validatePhone,
    );
  }

  Widget _buildDobWidget() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: _pickDob,
      validator: _validateDob,
    );
  }

  Widget _buildPasswordWidget() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
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

  Widget _loadingSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _initialSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _register(context),
        child: const Text('Register'),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext buildContext) {
    return Builder(
      builder: (buildContext) {
        return BlocBuilder<SignUpButtonStateCubit, SignUpButtonState>(
          builder: (context, state) {
            if (state is SignUpButtonLoadingState) {
              return _loadingSignUpButton();
            }
            return _initialSignUpButton(buildContext);
          },
        );
      },
    );
  }
}
