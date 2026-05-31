// Fixed UpdateNameScreen for page_one.dart
import 'package:demo_app/common/bloc/update_name/update_name_state.dart';
import 'package:demo_app/common/bloc/update_name/update_name_state_cubit.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/domain/usecases/update_name.dart';
import 'package:demo_app/domain/usecases/user_info.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_info.dart';
import '../../../screens/common_top_bar.dart';
import '../../../service_locator.dart';
import '../../drawer/drawer_config.dart';
import '../../home/pages/home_screen.dart';

class UpdateNameScreen extends StatefulWidget {
  final User userData;

  const UpdateNameScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _updateProfile(BuildContext ctx) {
    if (formKey.currentState!.validate()) {
      ctx.read<UpdateNameButtonStateCubit>().updateName(
        useCase: serviceLocator<UpdateNameUseCase>(),
        params: UpdateNamePayload(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              UpdateNameScreenCubit()..loadName(useCase: UserInfoUseCase()),
        ),
        BlocProvider(create: (context) => UpdateNameButtonStateCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateNameButtonStateCubit, UpdateNameButtonState>(
            listener: (context, state) {
              if (state is UpdateNameButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
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
              } else if (state is UpdateNameButtonFailureState) {
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
            title: 'Edit Name',
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          body: BlocBuilder<UpdateNameScreenCubit, UpdateNameScreenState>(
            builder: (context, state) {
              if (state is UpdateNameScreenLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UpdateNameScreenErrorState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UpdateNameScreenCubit>().loadName(
                            useCase: UserInfoUseCase(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is UpdateNameScreenLoadedState) {
                // Update controllers when data is loaded
                if (firstNameController.text != state.firstName) {
                  firstNameController.text = state.firstName;
                }
                if (lastNameController.text != state.lastName) {
                  lastNameController.text = state.lastName;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'Edit Your Profile',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update your first name and last name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // First Name Field
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Last Name Field
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        // Update Button
                        BlocBuilder<
                          UpdateNameButtonStateCubit,
                          UpdateNameButtonState
                        >(
                          builder: (context, buttonState) {
                            return ElevatedButton(
                              onPressed:
                                  buttonState is UpdateNameButtonLoadingState
                                  ? null
                                  : () => _updateProfile(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: const Color(0xFF3182CE),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: buttonState is UpdateNameButtonLoadingState
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        Text('Updating...'),
                                      ],
                                    )
                                  : const Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),

                        // Add some bottom padding to ensure content doesn't touch the screen edge
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('Something went wrong'));
            },
          ),
        ),
      ),
    );
  }
}
