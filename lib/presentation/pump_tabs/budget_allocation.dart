// tabs/allocations_tab.dart
import 'package:demo_app/data/models/land_allocation_creation_payload.dart';
import 'package:demo_app/data/models/land_allocation_delete_payload.dart';
import 'package:demo_app/data/models/land_allocation_dto.dart';
import 'package:demo_app/data/models/land_allocation_update_payload.dart';
import 'package:demo_app/presentation/pump_tabs/tab_design_tokens.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/land_allocation/land_allocation_state.dart';
import '../../common/bloc/land_allocation/land_allocation_state_cubit.dart';
import '../../domain/usecases/land_allocation.dart';

class AllocationsTab extends StatefulWidget {
  final int pumpStationId;

  const AllocationsTab({Key? key, required this.pumpStationId})
    : super(key: key);

  @override
  State<AllocationsTab> createState() => _AllocationsTabState();
}

class _AllocationsTabState extends State<AllocationsTab> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LandAllocationCubit()
            ..loadLandAllocation(
              useCase: serviceLocator<GetLandAllocationUseCase>(),
              params: widget.pumpStationId,
            ),
        ),
        BlocProvider(create: (_) => CreateLandAllocationButtonCubit()),
        BlocProvider(create: (_) => UpdateLandAllocationButtonCubit()),
        BlocProvider(create: (_) => DeleteLandAllocationButtonCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          // Create listener
          BlocListener<
            CreateLandAllocationButtonCubit,
            CreateLandAllocationButtonState
          >(
            listener: (context, state) {
              if (state is CreateLandAllocationButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Land allocation created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Add the new allocation to the list locally (no network call)
                context.read<LandAllocationCubit>().addAllocation(
                  state.allocation,
                );
              } else if (state is CreateLandAllocationButtonFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // Update listener
          BlocListener<
            UpdateLandAllocationButtonCubit,
            UpdateLandAllocationButtonState
          >(
            listener: (context, state) {
              if (state is UpdateLandAllocationButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Land allocation updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Update the allocation in the list locally (no network call)
                context.read<LandAllocationCubit>().updateAllocation(
                  state.allocation,
                );
              } else if (state is UpdateLandAllocationButtonFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // Delete listener
          BlocListener<
            DeleteLandAllocationButtonCubit,
            DeleteLandAllocationButtonState
          >(
            listener: (context, state) {
              if (state is DeleteLandAllocationButtonSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Land allocation deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Remove the allocation from the list locally (no network call)
                context.read<LandAllocationCubit>().removeAllocation(
                  state.allocationId,
                );
              } else if (state is DeleteLandAllocationButtonFailureState) {
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
        child: Builder(
          builder: (context) => Scaffold(
            body: _buildBody(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateDialog(context),
              backgroundColor: DesignTokens.brand,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LandAllocationCubit, LandAllocationState>(
      builder: (context, state) {
        if (state is LandAllocationLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: DesignTokens.brand,
              strokeWidth: 3,
            ),
          );
        }

        if (state is LandAllocationErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Allocations',
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
                      context.read<LandAllocationCubit>().refreshLandAllocation(
                        useCase: serviceLocator<GetLandAllocationUseCase>(),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is LandAllocationLoadedState) {
          if (state.allocationList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Land Allocations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create one',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LandAllocationCubit>().refreshLandAllocation(
                useCase: serviceLocator<GetLandAllocationUseCase>(),
                params: widget.pumpStationId,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.allocationList.length,
              itemBuilder: (context, index) {
                return _buildAllocationCard(
                  context,
                  state.allocationList[index],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAllocationCard(
    BuildContext context,
    LandAllocationDto allocation,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DesignTokens.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignTokens.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: DesignTokens.brand,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allocation.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: DesignTokens.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          allocation.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: DesignTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(context, allocation),
                    icon: const Icon(Icons.edit, size: 20),
                    color: DesignTokens.brand,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, allocation),
                    icon: const Icon(Icons.delete, size: 20),
                    color: DesignTokens.danger,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DesignTokens.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.landscape,
                  color: DesignTokens.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Land Area:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${allocation.amountOfLand.toStringAsFixed(2)} acres',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext parentContext) {
    final phoneController = TextEditingController();
    final landController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Capture the cubit BEFORE opening the dialog
    final createCubit = parentContext.read<CreateLandAllocationButtonCubit>();
    final allocationCubit = parentContext.read<LandAllocationCubit>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: createCubit,
        child: AlertDialog(
          title: const Text(
            'Create Land Allocation',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    // if (value.trim().length < 11) {
                    //   return 'Enter a valid phone number';
                    // }

                    // Check if phone number already exists
                    final state = allocationCubit.state;
                    if (state is LandAllocationLoadedState) {
                      final phoneExists = state.allocationList.any(
                        (allocation) => allocation.phone == value.trim(),
                      );

                      if (phoneExists) {
                        return 'Phone number already exists. Please edit the existing entry.';
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: landController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount of Land',
                    hintText: 'Enter land area in acres',
                    suffixText: 'acres',
                    prefixIcon: const Icon(Icons.landscape),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount of land is required';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            BlocBuilder<
              CreateLandAllocationButtonCubit,
              CreateLandAllocationButtonState
            >(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is CreateLandAllocationButtonLoadingState
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            final payload = LandAllocationCreationPayload(
                              pumpStationId: widget.pumpStationId,
                              phone: phoneController.text.trim(),
                              amountOfLand: double.parse(
                                landController.text.trim(),
                              ),
                            );

                            parentContext
                                .read<CreateLandAllocationButtonCubit>()
                                .createLandAllocation(
                                  params: payload,
                                  useCase:
                                      serviceLocator<
                                        CreateLandAllocationUseCase
                                      >(),
                                );

                            Navigator.pop(dialogContext);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.brand,
                  ),
                  child: state is CreateLandAllocationButtonLoadingState
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Create'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext parentContext,
    LandAllocationDto allocation,
  ) {
    final phoneController = TextEditingController(text: allocation.phone);
    final landController = TextEditingController(
      text: allocation.amountOfLand.toString(),
    );
    final formKey = GlobalKey<FormState>();

    // Capture the cubit BEFORE opening the dialog
    final updateCubit = parentContext.read<UpdateLandAllocationButtonCubit>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider.value(
        value: updateCubit,
        child: AlertDialog(
          title: const Text(
            'Edit Land Allocation',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: false, // Disable phone number field in edit mode
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: landController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount of Land',
                    hintText: 'Enter land area in acres',
                    suffixText: 'acres',
                    prefixIcon: const Icon(Icons.landscape),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount of land is required';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            BlocBuilder<
              UpdateLandAllocationButtonCubit,
              UpdateLandAllocationButtonState
            >(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is UpdateLandAllocationButtonLoadingState
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            final payload = LandAllocationUpdatePayload(
                              allocationId: allocation.id,
                              pumpStationId: widget.pumpStationId,
                              amountOfLand: double.parse(
                                landController.text.trim(),
                              ),
                            );

                            parentContext
                                .read<UpdateLandAllocationButtonCubit>()
                                .updateLandAllocation(
                                  params: payload,
                                  useCase:
                                      serviceLocator<
                                        UpdateLandAllocationUseCase
                                      >(),
                                );

                            Navigator.pop(dialogContext);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.brand,
                  ),
                  child: state is UpdateLandAllocationButtonLoadingState
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Update'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext parentContext,
    LandAllocationDto allocation,
  ) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete land allocation for ${allocation.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final payload = LandAllocationDeletePayload(
                allocationId: allocation.id,
                pumpStationId: widget.pumpStationId,
              );

              parentContext
                  .read<DeleteLandAllocationButtonCubit>()
                  .deleteLandAllocation(
                    params: payload,
                    useCase: serviceLocator<DeleteLandAllocationUseCase>(),
                  );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
