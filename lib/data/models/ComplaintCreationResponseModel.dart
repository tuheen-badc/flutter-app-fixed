class ComplaintCreationResponseModel {
  final int userId;
  final String message;

  ComplaintCreationResponseModel({required this.userId, required this.message});

  factory ComplaintCreationResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintCreationResponseModel(
      userId: json['userId'] as int,
      message: json['message'],
    );
  }
}
