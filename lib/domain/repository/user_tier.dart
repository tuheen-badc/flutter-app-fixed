import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';

import '../../data/models/pump_execution_payload.dart';
import '../../data/models/transaction_history_criteria.dart';

abstract class UserTierRepository {
  Future<Either> getUserTier(int userId);
}
