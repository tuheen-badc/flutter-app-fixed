// tabs/budget_tab.dart
import 'package:demo_app/data/models/water_budget_update_payload.dart';
import 'package:demo_app/presentation/pump_tabs/tab_design_tokens.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/water_budget/update_water_budget_state.dart';
import '../../common/bloc/water_budget/update_water_budget_state_cubit.dart';
import '../../domain/usecases/water_budget.dart';

class BudgetTab extends StatefulWidget {
  final int pumpStationId;

  const BudgetTab({Key? key, required this.pumpStationId}) : super(key: key);

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  int? _budgetId;
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _waterBudgetController = TextEditingController();
  final GlobalKey<FormState> _budgetFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _landAreaController.dispose();
    _waterBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      UpdateWaterBudgetButtonCubit,
      UpdateWaterBudgetButtonState
    >(
      listener: (context, state) {
        if (state is UpdateWaterBudgetButtonSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Water budget updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          final landArea = double.parse(_landAreaController.text.trim());
          final waterBudget = double.parse(_waterBudgetController.text.trim());

          context.read<UpdateWaterBudgetScreenCubit>().updateLocalState(
            totalLandArea: landArea,
            totalWater: waterBudget,
            budgetId: _budgetId!,
          );
        } else if (state is UpdateWaterBudgetButtonFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child:
          BlocBuilder<
            UpdateWaterBudgetScreenCubit,
            UpdateWaterBudgetScreenState
          >(
            builder: (context, state) {
              if (state is UpdateWaterBudgetScreenLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: DesignTokens.brand,
                    strokeWidth: 3,
                  ),
                );
              }

              if (state is UpdateWaterBudgetScreenFailureState) {
                return _buildErrorState(context, state);
              }

              if (state is UpdateWaterBudgetScreenSuccessState) {
                return _buildSuccessState(context, state);
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: DesignTokens.brand,
                  strokeWidth: 3,
                ),
              );
            },
          ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    UpdateWaterBudgetScreenFailureState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UpdateWaterBudgetScreenCubit>().loadWaterBudget(
                  useCase: serviceLocator<GetWaterBudgetUseCase>(),
                  params: widget.pumpStationId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.brand,
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

  Widget _buildSuccessState(
    BuildContext context,
    UpdateWaterBudgetScreenSuccessState state,
  ) {
    _budgetId = state.budgetId;

    if (_landAreaController.text.isEmpty) {
      _landAreaController.text = state.totalLandArea.toString();
    }
    if (_waterBudgetController.text.isEmpty) {
      _waterBudgetController.text = state.totalWater.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _budgetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentBudgetCard(state),
            const SizedBox(height: 20),
            _buildUpdateBudgetCard(context),
            const SizedBox(height: 20),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBudgetCard(UpdateWaterBudgetScreenSuccessState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DesignTokens.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: DesignTokens.brand,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBudgetStatCard(
                  'Land Area',
                  '${state.totalLandArea.toStringAsFixed(2)} acres',
                  Icons.landscape,
                  DesignTokens.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBudgetStatCard(
                  'Water Budget',
                  '${state.totalWater.toStringAsFixed(2)} L',
                  Icons.water,
                  DesignTokens.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateBudgetCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DesignTokens.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: DesignTokens.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Update Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLandAreaField(),
          const SizedBox(height: 16),
          _buildWaterBudgetField(),
          const SizedBox(height: 20),
          _buildUpdateButton(context),
        ],
      ),
    );
  }

  Widget _buildLandAreaField() {
    return TextFormField(
      controller: _landAreaController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Total Land Area',
        hintText: 'Enter land area in acres',
        suffixText: 'acres',
        prefixIcon: const Icon(Icons.landscape),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: DesignTokens.bg,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Land area is required';
        }
        final number = double.tryParse(value);
        if (number == null || number <= 0) {
          return 'Please enter a valid positive number';
        }
        return null;
      },
    );
  }

  Widget _buildWaterBudgetField() {
    return TextFormField(
      controller: _waterBudgetController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Total Water Budget',
        hintText: 'Enter water budget in liters',
        suffixText: 'Liters',
        prefixIcon: const Icon(Icons.water_drop),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: DesignTokens.bg,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Water budget is required';
        }
        final number = double.tryParse(value);
        if (number == null || number <= 0) {
          return 'Please enter a valid positive number';
        }
        return null;
      },
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return BlocBuilder<
      UpdateWaterBudgetButtonCubit,
      UpdateWaterBudgetButtonState
    >(
      builder: (context, buttonState) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: buttonState is UpdateWaterBudgetButtonLoadingState
                ? null
                : () => _updateWaterBudget(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: buttonState is UpdateWaterBudgetButtonLoadingState
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Updating...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Update Budget',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The water budget will be allocated based on the total land area. Ensure accurate values for optimal water distribution.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: DesignTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updateWaterBudget(BuildContext context) {
    if (_budgetFormKey.currentState!.validate()) {
      final landArea = double.parse(_landAreaController.text.trim());
      final waterBudget = double.parse(_waterBudgetController.text.trim());

      if (_budgetId == null) {
        return;
      }

      context.read<UpdateWaterBudgetButtonCubit>().updateWaterBudget(
        useCase: serviceLocator<UpdateWaterBudgetUseCase>(),
        params: WaterBudgetUpdatePayload(
          id: widget.pumpStationId,
          totalLandArea: landArea,
          totalWater: waterBudget,
        ),
      );
    }
  }
}
