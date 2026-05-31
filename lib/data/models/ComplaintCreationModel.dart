class ComplaintCreationModel {
  final String message;

  ComplaintCreationModel({required this.message});

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
