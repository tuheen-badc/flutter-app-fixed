// edit_water_pricing_screen.dart
import 'package:demo_app/common/bloc/water_pricing/water_pricing_state.dart';
import 'package:demo_app/data/models/user_info.dart';
import 'package:demo_app/domain/usecases/water_pricing.dart';
import 'package:demo_app/presentation/drawer/role_based_drawer_screen.dart';
import 'package:demo_app/screens/common_top_bar.dart';
import 'package:demo_app/screens/water_pricing_screen.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/bloc/water_pricing/water_pricing_state_cubit.dart';
import '../common/bloc/water_pricing_update/water_pricing_update_state.dart';
import '../common/bloc/water_pricing_update/water_pricing_update_state_cubit.dart';
import '../data/models/water_pricing_update_request.dart';
import '../domain/usecases/update_prcing.dart';

class EditWaterPricingScreen extends StatefulWidget {
  final User userData;

  const EditWaterPricingScreen({Key? key, required this.userData})
    : super(key: key);

  @override
  State<EditWaterPricingScreen> createState() => _EditWaterPricingScreenState();
}

class _EditWaterPricingScreenState extends State<EditWaterPricingScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tierOneController = TextEditingController();
  final TextEditingController tierTwoController = TextEditingController();
  final TextEditingController tierThreeController = TextEditingController();

  // Design tokens
  static const _surface = Color(0xFFFFFFFF);
  static const _bg = Color(0xFFF8F9FA);
  static const _textPrimary = Color(0xFF2D3748);
  static const _textSecondary = Color(0xFF718096);
  static const _border = Color(0xFFE2E8F0);
  static const _brand = Color(0xFF3182CE);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);

  @override
  void dispose() {
    tierOneController.dispose();
    tierTwoController.dispose();
    tierThreeController.dispose();
    super.dispose();
  }

  void _updatePricing(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = WaterPricingRequest(
      tierOneRate: double.parse(tierOneController.text),
      tierTwoRate: double.parse(tierTwoController.text),
      tierThreeRate: double.parse(tierThreeController.text),
    );

    context.read<UpdateWaterPricingCubit>().updateWaterPricing(
      useCase: serviceLocator<UpdateWaterPricingUseCase>(),
      params: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              WaterPricingCubit()
                ..execute(useCase: serviceLocator<WaterPricingUseCase>()),
        ),
        BlocProvider(create: (_) => UpdateWaterPricingCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateWaterPricingCubit, UpdateWaterPricingState>(
            listener: (context, state) {
              if (state is UpdateWaterPricingSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: _success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // Navigate to WaterPricingScreen
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WaterPricingScreen(userData: widget.userData),
                      ),
                    );
                  }
                });
              } else if (state is UpdateWaterPricingErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: _danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<UpdateWaterPricingCubit>().resetState();
              }
            },
          ),
        ],
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: RoleBasedDrawer(userData: widget.userData),
          appBar: CustomTopBar(
            title: 'Edit Water Pricing',
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          body: BlocBuilder<WaterPricingCubit, WaterPricingState>(
            builder: (context, state) {
              if (state is WaterPricingLoadingState) {
                return const _CenteredLoader();
              }

              if (state is WaterPricingErrorState) {
                return _ErrorView(
                  message: state.errorMessage,
                  onRetry: () {
                    context.read<WaterPricingCubit>().refresh(
                      useCase: serviceLocator<WaterPricingUseCase>(),
                    );
                  },
                );
              }

              if (state is WaterPricingLoadedState) {
                // Pre-fill controllers with loaded values
                if (tierOneController.text.isEmpty) {
                  tierOneController.text = state.pricing.tierOneRate
                      .toStringAsFixed(2);
                }
                if (tierTwoController.text.isEmpty) {
                  tierTwoController.text = state.pricing.tierTwoRate
                      .toStringAsFixed(2);
                }
                if (tierThreeController.text.isEmpty) {
                  tierThreeController.text = state.pricing.tierThreeRate
                      .toStringAsFixed(2);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tier 1 Rate
                          _TierRateCard(
                            tierNumber: 1,
                            tierName: 'Tier 1',
                            description: 'Basic Tier',
                            controller: tierOneController,
                            icon: Icons.water_drop_outlined,
                            iconColor: _success,
                            iconBgColor: const Color(0xFFD1FAE5),
                          ),

                          const SizedBox(height: 16),

                          // Tier 2 Rate
                          _TierRateCard(
                            tierNumber: 2,
                            tierName: 'Tier 2',
                            description: 'Moderate Consumption',
                            controller: tierTwoController,
                            icon: Icons.water_drop,
                            iconColor: _brand,
                            iconBgColor: const Color(0xFFEBF8FF),
                          ),

                          const SizedBox(height: 16),

                          // Tier 3 Rate
                          _TierRateCard(
                            tierNumber: 3,
                            tierName: 'Tier 3 (∞)',
                            description: 'High Consumption',
                            controller: tierThreeController,
                            icon: Icons.water,
                            iconColor: _warning,
                            iconBgColor: const Color(0xFFFFF4E6),
                          ),

                          const SizedBox(height: 24),

                          // Update Button
                          BlocBuilder<
                            UpdateWaterPricingCubit,
                            UpdateWaterPricingState
                          >(
                            builder: (context, buttonState) {
                              final isLoading =
                                  buttonState is UpdateWaterPricingLoadingState;

                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _updatePricing(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brand,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor: _textSecondary,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.save, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Update Pricing',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Cancel Button - Enhanced
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _danger,
                                side: const BorderSide(
                                  color: _danger,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const _CenteredLoader();
            },
          ),
        ),
      ),
    );
  }

  static BoxDecoration get _cardDecoration => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// --- Reusable Widgets ---

class _TierRateCard extends StatelessWidget {
  final int tierNumber;
  final String tierName;
  final String description;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _TierRateCard({
    required this.tierNumber,
    required this.tierName,
    required this.description,
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tierName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rate Input
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Rate per Liter (৳)',
              hintText: 'Enter rate',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Center(
                  widthFactor: 0,
                  child: Text(
                    '৳',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF3182CE),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter tier $tierNumber rate';
              }
              final rate = double.tryParse(value);
              if (rate == null) {
                return 'Please enter a valid number';
              }
              if (rate <= 0) {
                return 'Rate must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
          color: Color(0xFF3182CE),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Pricing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
