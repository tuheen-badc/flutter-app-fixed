// electricity_availability_state.dart
import 'package:equatable/equatable.dart';

import '../../../data/models/electricity_status.dart';

abstract class ElectricityAvailabilityState extends Equatable {
  const ElectricityAvailabilityState();

  @override
  List<Object?> get props => [];
}

class ElectricityAvailabilityInitialState
    extends ElectricityAvailabilityState {}

class ElectricityAvailabilityLoadingState
    extends ElectricityAvailabilityState {}

class ElectricityAvailabilityLoadedState extends ElectricityAvailabilityState {
  final List<ElectricityAvailabilityIndicator> statusList;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  const ElectricityAvailabilityLoadedState({
    required this.statusList,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });

  @override
  List<Object?> get props => [
    statusList,
    currentPage,
    totalPages,
    totalElements,
  ];
}

class ElectricityAvailabilityErrorState extends ElectricityAvailabilityState {
  final String errorMessage;

  const ElectricityAvailabilityErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
