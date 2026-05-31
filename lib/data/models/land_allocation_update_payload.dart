class LandAllocationUpdatePayload {
  final int pumpStationId;
  final int allocationId;
  final double amountOfLand;

  LandAllocationUpdatePayload({
    required this.pumpStationId,
    required this.allocationId,
    required this.amountOfLand,
  });

  Map<String, dynamic> toJson() {
    return {'amountOfLand': amountOfLand};
  }
}
