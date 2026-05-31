import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/data/models/signup_payload.dart';

abstract class CreditRepository {
  Future<Either> userCreditInfo();
}
