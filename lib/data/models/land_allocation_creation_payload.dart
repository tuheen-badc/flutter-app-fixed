class LandAllocationCreationPayload {
  final int pumpStationId;
  final String phone;
  final double amountOfLand;

  LandAllocationCreationPayload({
    required this.pumpStationId,
    required this.phone,
    required this.amountOfLand,
  });

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'amountOfLand': amountOfLand};
  }
}
