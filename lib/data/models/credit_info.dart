import 'package:decimal/decimal.dart';

class UserCreditResponseModel {
  final Decimal availableCredit;
  final DateTime lastUpdatedAt;

  UserCreditResponseModel({
    required this.availableCredit,
    required this.lastUpdatedAt,
  });

  factory UserCreditResponseModel.fromJson(Map<String, dynamic> json) {
    return UserCreditResponseModel(
      availableCredit: Decimal.parse(json['availableCredit'].toString()),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'].toString()),
    );
  }
}
